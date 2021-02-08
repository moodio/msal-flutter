

class BrowserDescriptor {
  final String packageName;
  final String versionLowerBound;
  final String versionUpperBound;
  final List<String> signatureHashes;

  BrowserDescriptor(
      {this.packageName,
      this.versionLowerBound,
      this.versionUpperBound,
      this.signatureHashes});

  Map<String, dynamic> toJson() {
    return {
      "browser_package_name": packageName,
      "browser_version_upper_bound": versionUpperBound,
      "browser_version_lower_bound": versionLowerBound,
      "browser_signature_hashes": signatureHashes,
    };
  }
}
