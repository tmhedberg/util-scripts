#!/bin/awk -f

{
	printf "private %s %s;\n", $1, $2;

	cap = sprintf("%s%s", toupper(substr($2, 1, 1)), substr($2, 2));

	get[NR] = sprintf("public %s get%s() {\n    return %s;\n}", $1, cap, $2);
	set[NR] = sprintf("public void set%s(final %s %s) {\n    this.%s = %s;\n}", cap, $1, $2, $2, $2);
}

END {
	printf "\n";
	for (i = 1; i <= NR; ++i) {
		print get[i];
		print set[i];
		printf "\n";
	}
}
