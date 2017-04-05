using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(OnlinePharmacy.Startup))]
namespace OnlinePharmacy
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            
        }
    }
}
