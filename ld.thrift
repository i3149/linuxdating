/**
        Thift interface for LinuxDating.com
*/


namespace cpp linuxdating
namespace php linuxdating
namespace perl linuxdating

typedef string LDCommand
typedef string LDResponse

service LinuxDater {

   void ping(),

   LDResponse eval_command(1:LDCommand cmd)
}