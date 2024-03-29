//
//  Remotes.swift
//  SwiftGit2
//
//  Created by Matt Diephouse on 1/2/15.
//  Copyright (c) 2015 GitHub, Inc. All rights reserved.
//



/// A remote in a git repository.
public struct Remote {
    public let pointer: OpaquePointer
	/// The name of the remote.
	public let name: String

	/// The URL of the remote.
	///
	/// This may be an SSH URL, which isn't representable using `NSURL`.
	public let URL: String

	/// Create an instance with a libgit2 `git_remote`.
	public init(_ pointer: OpaquePointer) {
        self.pointer = pointer
		name = String(validatingUTF8: git_remote_name(pointer))!
		URL = String(validatingUTF8: git_remote_url(pointer))!
	}
}

extension Remote: Hashable {
	public var hashValue: Int {
		return name.hashValue ^ URL.hashValue
	}
}

public func == (lhs: Remote, rhs: Remote) -> Bool {
	return lhs.name == rhs.name && lhs.URL == rhs.URL
}
