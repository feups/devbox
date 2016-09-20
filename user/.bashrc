function presources () {
    puppetresources -p . -o $1 --hiera ./tests/hiera.yaml --pdbfile tests/facts.yaml ''${@:2}
}

export PS1='\w\[\033[01;38m\]$(__git_ps1)\[\033[00m\] → '
