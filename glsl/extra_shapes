
vec3 n1 = vec3(1.000,0.000,0.000);
vec3 n2 = vec3(0.000,1.000,0.000);
vec3 n3 = vec3(0.000,0.000,1.000);
vec3 n4 = vec3(0.577,0.577,0.577);
vec3 n5 = vec3(-0.577,0.577,0.577);
vec3 n6 = vec3(0.577,-0.577,0.577);
vec3 n7 = vec3(0.577,0.577,-0.577);
vec3 n8 = vec3(0.000,0.357,0.934);
vec3 n9 = vec3(0.000,-0.357,0.934);
vec3 n10 = vec3(0.934,0.000,0.357);
vec3 n11 = vec3(-0.934,0.000,0.357);
vec3 n12 = vec3(0.357,0.934,0.000);
vec3 n13 = vec3(-0.357,0.934,0.000);
vec3 n14 = vec3(0.000,0.851,0.526);
vec3 n15 = vec3(0.000,-0.851,0.526);
vec3 n16 = vec3(0.526,0.000,0.851);
vec3 n17 = vec3(-0.526,0.000,0.851);
vec3 n18 = vec3(0.851,0.526,0.000);
vec3 n19 = vec3(-0.851,0.526,0.000);

// p as usual, e exponent (p in the paper), r radius or something like that
float octahedral(vec3 p, float e, float r) {
	float s = pow(abs(dot(p,n4)),e);
	s += pow(abs(dot(p,n5)),e);
	s += pow(abs(dot(p,n6)),e);
	s += pow(abs(dot(p,n7)),e);
	s = pow(s, 1./e);
	return s-r;
}


float dodecahedral(vec3 p, float e, float r) {
	float s = pow(abs(dot(p,n14)),e);
	s += pow(abs(dot(p,n15)),e);
	s += pow(abs(dot(p,n16)),e);
	s += pow(abs(dot(p,n17)),e);
	s += pow(abs(dot(p,n18)),e);
	s += pow(abs(dot(p,n19)),e);
	s = pow(s, 1./e);
	return s-r;
}

float icosahedral(vec3 p, float e, float r) {
	float s = pow(abs(dot(p,n4)),e);
	s += pow(abs(dot(p,n5)),e);
	s += pow(abs(dot(p,n6)),e);
	s += pow(abs(dot(p,n7)),e);
	s += pow(abs(dot(p,n8)),e);
	s += pow(abs(dot(p,n9)),e);
	s += pow(abs(dot(p,n10)),e);
	s += pow(abs(dot(p,n11)),e);
	s += pow(abs(dot(p,n12)),e);
	s += pow(abs(dot(p,n13)),e);
	s = pow(s, 1./e);
	return s-r;
}

float toctahedral(vec3 p, float e, float r) {
	float s = pow(abs(dot(p,n1)),e);
	s += pow(abs(dot(p,n2)),e);
	s += pow(abs(dot(p,n3)),e);
	s += pow(abs(dot(p,n4)),e);
	s += pow(abs(dot(p,n5)),e);
	s += pow(abs(dot(p,n6)),e);
	s += pow(abs(dot(p,n7)),e);
	s = pow(s, 1./e);
	return s-r;
}

float ticosahedral(vec3 p, float e, float r) {
	float s = pow(abs(dot(p,n4)),e);
	s += pow(abs(dot(p,n5)),e);
	s += pow(abs(dot(p,n6)),e);
	s += pow(abs(dot(p,n7)),e);
	s += pow(abs(dot(p,n8)),e);
	s += pow(abs(dot(p,n9)),e);
	s += pow(abs(dot(p,n10)),e);
	s += pow(abs(dot(p,n11)),e);
	s += pow(abs(dot(p,n12)),e);
	s += pow(abs(dot(p,n13)),e);
	s += pow(abs(dot(p,n14)),e);
	s += pow(abs(dot(p,n15)),e);
	s += pow(abs(dot(p,n16)),e);
	s += pow(abs(dot(p,n17)),e);
	s += pow(abs(dot(p,n18)),e);
	s += pow(abs(dot(p,n19)),e);
	s = pow(s, 1./e);
	return s-r;
}