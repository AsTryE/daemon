#include <dlfcn.h> 
#import "../Constant.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
    Stuff;\
    _Pragma("clang diagnostic pop") \
} while (0)



// static bool IsJiShuaAppRunning() {

//     NSString *bundleID = @"com.elvis.NTJiShua";
//     void *handle = dlopen("/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices", 1);
//     bool (*SBSProcessIDForDisplayIdentifier)(CFStringRef, int *);
//     SBSProcessIDForDisplayIdentifier = (bool (*)(CFStringRef, int *))dlsym(handle, "SBSProcessIDForDisplayIdentifier");
//     int pid;
//     BOOL result =  SBSProcessIDForDisplayIdentifier((__bridge CFStringRef)bundleID, &pid);

//     NSLog(@"pid is %d, result is %d", pid, result);


//     return result;
// }




//启动我们的机刷应用
// static bool OpenJiShuaApplication() {

//     NSString *bundleID = @"com.nineton.ntasoapp";

//     void *handle = dlopen("/System/Library/Frameworks/MobileCoreServices.framework/MobileCoreServices", RTLD_LAZY);

//     Class LSApplicationWorkspace = NSClassFromString(@"LSApplicationWorkspace");
//     if (LSApplicationWorkspace == nil)
//     {
//         return false;
//     }

//     id workspace;
//     SuppressPerformSelectorLeakWarning(
//         workspace = [LSApplicationWorkspace performSelector:NSSelectorFromString(@"defaultWorkspace")]
//     );
    
//     if (workspace == nil)
//     {
//         return false;
//     }

//     bool ret;

//     SuppressPerformSelectorLeakWarning(

//         ret = [workspace performSelector:NSSelectorFromString(@"openApplicationWithBundleID:") withObject:bundleID]
//     );
    
//     dlclose(handle);

//     return ret;
// }

// //收到应用退出的通知后10秒后重启app
// static void RestartJiShuaApp(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
//     NSLog(@"%@",@"ezsystemd: RestartJiShuaApp");
//     // dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//     OpenJiShuaApplication();
//     // });
// }


//通过system执行命令，并将执行结果写到文件里
static void ExecuteCommand(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    
    NSLog(@"enter %@",@"ezsystemd: ExecuteCommand");
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:NT_FILEPATH_COMMAND]) {
        
        NSString *command = [NSString stringWithContentsOfFile:NT_FILEPATH_COMMAND encoding:NSUTF8StringEncoding error:nil];
        if (command != nil) {
            
            NSMutableString* resultStr = [[NSMutableString alloc] init];

            NSArray *cmds = [command componentsSeparatedByString:@";"];

            for (int i = 0; i < cmds.count; ++i)
            {
                
                NSString *cmd = [cmds[i] stringByReplacingOccurrencesOfString:@";" withString:@""];
                const char* cCommand = [cmd cStringUsingEncoding:NSUTF8StringEncoding];
                int result = system(cCommand);
                NSLog(@"ezsystemd: ExecuteCommand at index(%d) is %@, result is %d",i,cmd,result);
                NSString *seperator = i == cmds.count-1 ? @"" : @";";
                NSString *commandResStr = [NSString stringWithFormat:@"%@ %d%@",cmd,result,seperator];
                [resultStr appendString:commandResStr];
            }

            [resultStr writeToFile:NT_FILEPATH_COMMAND_RESULT atomically:true encoding:NSUTF8StringEncoding error:nil];

        }
        else {

            [@"0" writeToFile:NT_FILEPATH_COMMAND_RESULT atomically:true encoding:NSUTF8StringEncoding error:nil];
        }
    }
    else {

        [@"0" writeToFile:NT_FILEPATH_COMMAND_RESULT atomically:true encoding:NSUTF8StringEncoding error:nil];
    }

    NSLog(@"exit %@",@"ezsystemd: ExecuteCommand");
}

static BOOL IsASOAppRunning() {


    NSLog(@"ezsystemd enter IsASOAppRunning");

    NSString *heartbeatTimeStamp = [NSString stringWithContentsOfFile:NT_FILEPATH_HEARTBEAT encoding:NSUTF8StringEncoding error:nil];
    if (heartbeatTimeStamp == nil)
    {
        NSLog(@"ezsystemd no heartbeat");
        return true;
    }

    NSString *flag = [NSString stringWithContentsOfFile:NT_FILEPATH_COMMAND_FLAG encoding:NSUTF8StringEncoding error:nil];
    if (flag && [flag isEqualToString:@"1"])
    {
        NSLog(@"killed by master. don't restart");
        return true;
    }

    NSTimeInterval heartbeat = [heartbeatTimeStamp doubleValue];
    NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval allowd = 3 * 60;

    if ((current - heartbeat) < allowd )
    {
        NSLog(@"ezsystemd maybe running");
        return true;
    }
    else {

        NSLog(@"ezsystemd is not running");
        return false;
    }
}

int main(int argc, char **argv, char **envp) {
    
    NSLog(@"ezsystemd is launched");
    
    // CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, ExecuteCommand, CFSTR(NT_NOTIFY_COMMAND), NULL, CFNotificationSuspensionBehaviorCoalesce);

    // dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    // dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    // dispatch_source_set_event_handler(timer, ^{

    //     if (!IsASOAppRunning())
    //     {
    //         NSString *cmd = [NSString stringWithFormat:@"rm -fr %@",NT_FILEPATH_HEARTBEAT];
    //         system([cmd cStringUsingEncoding:NSUTF8StringEncoding]);
    //         system("killall -9 SpringBoard");
    //     }
    // });
    // dispatch_resume(timer);

    CFRunLoopRun();
    
	return 0;
}

// vim:ft=objc
