#run {
    args := get_build_options().compile_time_command_line;
    path := "bin";
    name := "exec";

    set_working_directory(#filepath);
    set_build_options_dc(.{do_output=false});
    
    success := build_project(path, name);
    if !success return;

    if args.count > 0 && args[0] == "run" {
        exec_path := sprint("./%/%", path, name);

        run_args := args;
        run_args.count -= 1;
        run_args.data += 1;

        run_project(exec_path, run_args);
    }
}

run_project :: (exec_path: string, args: []string) {
    new_args: [..]string;
    array_add(*new_args, exec_path);
    array_add(*new_args, ..args);
    log("===== RUNNING: % =====\n", join(..new_args, separator=" "));
    run_command(..new_args);
} 

build_project :: (path: string, name: string) -> success: bool {
    log("===== BUILDING =====\n");
    workspace := compiler_create_workspace("Lang Workspace");
    if !workspace {
        log_error("Failed to create workspace.\n");
        return false;
    }

    
    make_directory_if_it_does_not_exist(path);
    make_directory_if_it_does_not_exist("modules");

    
    opts := get_build_options(workspace);

    opts.output_executable_name = name;
    opts.output_path = path;

    import_path: [..]string;
    array_add(*import_path, "modules/");
    array_add(*import_path, ..opts.import_path);
    opts.import_path = import_path;

    set_build_options(opts, workspace);


    compiler_begin_intercept(workspace);
    add_build_file("src/main.jai", workspace);

    success := true;
    while true {
        msg := compiler_wait_for_message();
        if !msg break;
        if msg.kind == {
            case .COMPLETE; break;
            case .ERROR; success = false;
        }
    }
    compiler_end_intercept(workspace);

    if !success then log_error("Failed to build project.\n");
    else log("Build success.\n");

    return success;
}

#import "File";
#import "Basic";
#import "String";
#import "Process";
#import "Compiler";
