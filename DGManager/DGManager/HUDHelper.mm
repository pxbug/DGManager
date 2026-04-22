#import <spawn.h>
#import <notify.h>
#import <mach-o/dyld.h>
#import <string>
#import <objc/runtime.h>
#import <objc/message.h>
#import <Foundation/Foundation.h>

#define FADE_OUT_DURATION 0.25

extern "C" char **environ;

#define POSIX_SPAWN_PERSONA_FLAGS_OVERRIDE 1
extern "C" int posix_spawnattr_set_persona_np(const posix_spawnattr_t* __restrict, uid_t, uint32_t);
extern "C" int posix_spawnattr_set_persona_uid_np(const posix_spawnattr_t* __restrict, uid_t);
extern "C" int posix_spawnattr_set_persona_gid_np(const posix_spawnattr_t* __restrict, uid_t);

OBJC_EXTERN void CleanKeychains(NSString* where)
{
    posix_spawnattr_t attr;
    posix_spawnattr_init(&attr);

    posix_spawnattr_set_persona_np(&attr, 99, POSIX_SPAWN_PERSONA_FLAGS_OVERRIDE);
    posix_spawnattr_set_persona_uid_np(&attr, 0);
    posix_spawnattr_set_persona_gid_np(&attr, 0);

    static char *executablePath = NULL;
    uint32_t executablePathSize = 0;
    _NSGetExecutablePath(NULL, &executablePathSize);
    executablePath = (char *)calloc(1, executablePathSize);
    _NSGetExecutablePath(executablePath, &executablePathSize);
    
    pid_t task_pid;

    posix_spawnattr_setpgroup(&attr, 0);
    posix_spawnattr_setflags(&attr, POSIX_SPAWN_SETPGROUP);
    
    const char *args[] = {executablePath, "-CleanKeychains", where.UTF8String,"c", NULL };
    NSLog(@"%s",executablePath);
    posix_spawn(&task_pid, executablePath, NULL, &attr, (char **)args, environ);
    posix_spawnattr_destroy(&attr);
    int status;
    do {
        if (waitpid(task_pid, &status, 0) != -1)
        {
        }
    } while (!WIFEXITED(status) && !WIFSIGNALED(status));
}
OBJC_EXTERN void SetPaste(NSString* where,int auth)
{
    posix_spawnattr_t attr;
    posix_spawnattr_init(&attr);

    posix_spawnattr_set_persona_np(&attr, 99, POSIX_SPAWN_PERSONA_FLAGS_OVERRIDE);
    posix_spawnattr_set_persona_uid_np(&attr, 0);
    posix_spawnattr_set_persona_gid_np(&attr, 0);

    static char *executablePath = NULL;
    uint32_t executablePathSize = 0;
    _NSGetExecutablePath(NULL, &executablePathSize);
    executablePath = (char *)calloc(1, executablePathSize);
    _NSGetExecutablePath(executablePath, &executablePathSize);
    
    pid_t task_pid;

    posix_spawnattr_setpgroup(&attr, 0);
    posix_spawnattr_setflags(&attr, POSIX_SPAWN_SETPGROUP);
    
    std::string str = std::to_string(auth);
    const char* cstr = str.c_str();
    const char *args[] = {executablePath, "-SetPaste", where.UTF8String,cstr, NULL };
    posix_spawn(&task_pid, executablePath, NULL, &attr, (char **)args, environ);
    posix_spawnattr_destroy(&attr);
    int status;
    do {
        if (waitpid(task_pid, &status, 0) != -1)
        {
        }
    } while (!WIFEXITED(status) && !WIFSIGNALED(status));
}
OBJC_EXTERN void SetPermissions(NSString* where, int auth)
{
    posix_spawnattr_t attr;
    posix_spawnattr_init(&attr);

    // 设置进程为 root 权限
    posix_spawnattr_set_persona_np(&attr, 99, POSIX_SPAWN_PERSONA_FLAGS_OVERRIDE);
    posix_spawnattr_set_persona_uid_np(&attr, 0);
    posix_spawnattr_set_persona_gid_np(&attr, 0);

    // 获取可执行文件路径
    static char *executablePath = NULL;
    uint32_t executablePathSize = 0;
    _NSGetExecutablePath(NULL, &executablePathSize);
    executablePath = (char *)calloc(1, executablePathSize);
    _NSGetExecutablePath(executablePath, &executablePathSize);

    pid_t task_pid;

    // 设置进程组并启动进程
    posix_spawnattr_setpgroup(&attr, 0);
    posix_spawnattr_setflags(&attr, POSIX_SPAWN_SETPGROUP);

    // 将权限值转换为字符串
    std::string str = std::to_string(auth);
    const char* cstr = str.c_str();
    const char *args[] = {executablePath, "-SetPermissions", where.UTF8String, cstr, NULL};
    
    // 启动进程执行命令
    posix_spawn(&task_pid, executablePath, NULL, &attr, (char **)args, environ);
    posix_spawnattr_destroy(&attr);

    // 等待进程退出
    int status;
    do {
        if (waitpid(task_pid, &status, 0) != -1)
        {
        }
    } while (!WIFEXITED(status) && !WIFSIGNALED(status));
}
