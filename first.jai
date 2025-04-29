OUTPUT_PATH       :: "bin";
INTERMEDIATE_PATH :: ".build";
EXE_NAME          :: "lang";

#run,stallable {
    set_build_options_dc(.{ do_output = false });

    args := get_build_options().compile_time_command_line;

    no_build := array_find(args, "nobuild");
    do_run   := array_find(args, "run");

    if no_build == false && !build() {
        compiler_set_workspace_status(.FAILED);
        return;
    }

    if do_run == true && !run() {
        compiler_set_workspace_status(.FAILED);
        return;
    }
}

run :: () -> success: bool {
    print("==== Running ====\n");

    command := tprint("%/%", OUTPUT_PATH, EXE_NAME);

    result := run_command(command, print_captured_output = true);

    return result.exit_code == 0;
}

build :: () -> success: bool {
    print("==== Building ====\n");

    workspace := compiler_create_workspace("Dani Jam 2025");
    if !workspace {
        log_error("Failed to create workspace.\n");
        return false;
    }

    // Set up output path
    make_directory_if_it_does_not_exist(OUTPUT_PATH);
    if !write_entire_file(tprint("%/.gitignore", OUTPUT_PATH), "*\n") {
        log_error("Unable to create .gitignore file for ./%\n", OUTPUT_PATH);
    }

    // Set up intermediate path
    make_directory_if_it_does_not_exist(INTERMEDIATE_PATH);
    if !write_entire_file(tprint("%/.gitignore", INTERMEDIATE_PATH), "*\n") {
        log_error("Unable to create .gitignore file for ./%\n", INTERMEDIATE_PATH);
    }

    { // Set build options.
        opts := get_build_options(workspace);

        { // Tell linker to link math.h
            args: [..]string;
            array_add(*args, ..opts.additional_linker_arguments);
            array_add(*args, "-lm");
            opts.additional_linker_arguments = args;
        }

        ////////////////////////
        //////// Release ///////
        //set_optimization(*opts, .OPTIMIZED);
        //opts.backend = .LLVM;
        ///////// Debug ////////
        set_optimization(*opts, .DEBUG);
        opts.backend = .X64;
        ////////////////////////

        opts.text_output_flags = .OUTPUT_TIMING_INFO;

        opts.output_path = OUTPUT_PATH;
        opts.output_executable_name = EXE_NAME;

        opts.intermediate_path = INTERMEDIATE_PATH;

        set_build_options(opts, workspace);
    }

    { // Hook into compiler message loop to see if the build fails.
        compiler_begin_intercept(workspace);
        add_build_file("src/main.jai", workspace);

        success := true;
        while success {
            message := compiler_wait_for_message();
            if message.kind == {
                case .COMPLETE;
                    break;
                case .ERROR;
                    log_error("Failed during compile\n");
                    success = false;
            }
        }

        compiler_end_intercept(workspace);
        return success;
    }
}

#import "File";
#import "Basic";
#import "Process";
#import "Compiler";
