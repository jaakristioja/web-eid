#
# Copyright (c) 2023 Jaak Ristioja
#
# SPDX-License-Identifier: MIT
#

EAPI=8

inherit cmake

DESCRIPTION="C++ library for performing cryptographic operations with electronic identification (eID) cards."
HOMEPAGE="https://github.com/web-eid/libelectronic-id"
SRC_URI="https://github.com/web-eid/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

RESTRICT="!test? ( test )"

RDEPEND="
	sys-apps/pcsc-lite
	test? (
		dev-libs/libpcsc-mock
	)
"

DEPEND="${RDEPEND}
	>=dev-libs/openssl-1.1.1
	sys-libs/libpcsc-cpp
	test? (
		dev-cpp/gtest
	)
"

PATCHES=(
	"${FILESDIR}"/${P}-disable-system-integration-tests.patch
	"${FILESDIR}"/${P}-tests-optional.patch
)

src_prepare() {
	# Build a shared library instead of static library:
	sed -i -e 's/STATIC/SHARED/' CMakeLists.txt

	# Use system dev-cpp/magic_enum:
	sed -i -e 's%"magic_enum/magic_enum.hpp"%<magic_enum.hpp>%' \
		src/electronic-id.cpp

	# Use system dev-libs/libpcsc-mock:
	cmake_comment_add_subdirectory lib/libpcsc-cpp

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test)
	)
	cmake_src_configure
}

src_install() {
	dodoc LICENSE README.md

	if use test; then
		mkdir include/electronic-id/test
		cp tests/mock/*.hpp include/electronic-id/test/
	fi
	doheader -r include/electronic-id
    newlib.so "${BUILD_DIR}"/libelectronic-id.so libelectronic-id.so
}
