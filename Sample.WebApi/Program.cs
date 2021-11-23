using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;

namespace Sample.WebApi
{
    public static class Program
    {
        public static void Main(string[] args) =>
            CreateHostBuilder(args).Build().Run();

        private static IWebHostBuilder CreateHostBuilder(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                .UseKestrel()
                .UseIISIntegration()
                .UseStartup<Startup>();
    }
}
