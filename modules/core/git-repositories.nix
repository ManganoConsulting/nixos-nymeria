{
  # Git repositories configuration
  # This file defines all git repositories that should be managed by NixOS
  
  gitRepositories = {
    # Analysis repositories (worktrees of the same repo)
    analysis = {
      url = "git@github.com:ManganoConsulting/Analysis.git";
      branch = "main";
      path = "/home/matthew/GithubProjects/Analysis";
      worktrees = [
        {
          name = "Analysis-matlab";
          path = "/home/matthew/GithubProjects/Analysis-matlab";
          branch = "main";
        }
        {
          name = "Analysis-python";
          path = "/home/matthew/GithubProjects/Analysis-python";
          branch = "main";
        }
        {
          name = "Analysis-python-app";
          path = "/home/matthew/GithubProjects/Analysis-python-app";
          branch = "main";
        }
      ];
    };

    # ControlDesign repositories (worktrees of the same repo)
    controlDesign = {
      url = "git@github.com:ManganoConsulting/ControlDesign.git";
      branch = "main";
      path = "/home/matthew/GithubProjects/ControlDesign";
      worktrees = [
        {
          name = "ControlDesign-matlab";
          path = "/home/matthew/GithubProjects/ControlDesign-matlab";
          branch = "main";
        }
        {
          name = "ControlDesign-python";
          path = "/home/matthew/GithubProjects/ControlDesign-python";
          branch = "main";
        }
      ];
    };

    # Individual repositories
    compliance-copilot-mvp = {
      url = "git@github.com:ManganoConsulting/compliance-copilot-mvp.git";
      branch = "main";
      path = "/home/matthew/GithubProjects/compliance-copilot-mvp";
    };

    controlstackai-portal = {
      url = "git@github.com:ManganoConsulting/controlstackai-portal.git";
      branch = "main";
      path = "/home/matthew/GithubProjects/controlstackai-portal";
    };

    controlstackai-site = {
      url = "git@github.com:ManganoConsulting/controlstackai-site.git";
      branch = "main";
      path = "/home/matthew/GithubProjects/controlstackai-site";
    };

    diva = {
      url = "git@github.com:ManganoConsulting/DIVA.git";
      branch = "main";
      path = "/home/matthew/GithubProjects/DIVA";
    };

    gfdcl = {
      url = "git@github.com:ManganoConsulting/gfdcl.git";
      branch = "main";
      path = "/home/matthew/GithubProjects/gfdcl";
    };

    ghostty-ai = {
      url = "git@github.com:ManganoConsulting/ghostty.git";
      branch = "main";
      path = "/home/matthew/GithubProjects/ghostty-ai";
    };

    ilife = {
      url = "git@github.com:ManganoConsulting/ilife.git";
      branch = "main";
      path = "/home/matthew/GithubProjects/ilife";
    };

    library-matlab = {
      url = "git@github.com:ManganoConsulting/library-matlab.git";
      branch = "main";
      path = "/home/matthew/GithubProjects/library-matlab";
    };

    lift = {
      url = "git@github.com:ManganoConsulting/LIFT.git";
      branch = "main";
      path = "/home/matthew/GithubProjects/LIFT";
    };

    matlab-mcp-server = {
      url = "git@github.com:WilliamCloudQi/matlab-mcp-server.git";
      branch = "main";
      path = "/home/matthew/GithubProjects/matlab-mcp-server";
    };

    matlab-mcp-tools = {
      url = "git@github.com:neuromechanist/matlab-mcp-tools.git";
      branch = "main";
      path = "/home/matthew/GithubProjects/matlab-mcp-tools";
    };

    matlab-terminal = {
      url = "git@github.com:ManganoConsulting/matlab-terminal.git";
      branch = "main";
      path = "/home/matthew/GithubProjects/matlab-terminal";
    };

    matthew-mangano-cloudflare-portfolio = {
      url = "git@github.com:ManganoConsulting/matthew-mangano-cloudflare-portfolio.git";
      branch = "main";
      path = "/home/matthew/GithubProjects/matthew-mangano-cloudflare-portfolio";
    };

    mterm = {
      url = "git@github.com:ManganoConsulting/mterm.git";
      branch = "main";
      path = "/home/matthew/GithubProjects/mterm";
    };

    nixos-nymeria = {
      url = "git@github.com:ManganoConsulting/nixos-nymeria.git";
      branch = "main";
      path = "/home/matthew/GithubProjects/nixos-nymeria";
    };

    nvim = {
      url = "git@github.com:ManganoConsulting/nvim.git";
      branch = "main";
      path = "/home/matthew/GithubProjects/nvim";
    };

    sidpac = {
      url = "git@github.com:ManganoConsulting/SIDPAC.git";
      branch = "main";
      path = "/home/matthew/GithubProjects/SIDPAC";
    };

    simulink = {
      url = "git@github.com:ManganoConsulting/simulink.git";
      branch = "main";
      path = "/home/matthew/GithubProjects/simulink";
    };

    tools = {
      url = "git@github.com:ManganoConsulting/tools.git";
      branch = "main";
      path = "/home/matthew/GithubProjects/tools";
    };

    waveterm = {
      url = "git@github.com:ManganoConsulting/waveterm.git";
      branch = "main";
      path = "/home/matthew/GithubProjects/waveterm";
    };
  };
}