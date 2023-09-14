#
# Copyright (c) 2023 Jaak Ristioja
#
# SPDX-License-Identifier: MIT
#

EAPI=8

inherit cmake

DESCRIPTION="C++ library for accessing smart cards using the PC/SC API."
HOMEPAGE="https://github.com/web-eid/libpcsc-cpp"
SRC_URI="https://github.com/web-eid/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

RESTRICT="!test? ( test )"

RDEPEND="
	sys-apps/pcsc-lite
"

DEPEND="${RDEPEND}
	dev-cpp/magic_enum
	virtual/pkgconfig

	test? (
		dev-libs/libpcsc-mock
		dev-cpp/gtest
	)
"

PATCHES=(
	"${FILESDIR}"/${P}-disable-system-integration-tests.patch
	"${FILESDIR}"/${P}-pcsc-lite-include.patch
	"${FILESDIR}"/${P}-tests-optional.patch
)

src_prepare() {
	# Build a shared library instead of static library:
	sed -i -e 's/STATIC/SHARED/' CMakeLists.txt

	# Fix linking with libpcsclite:
	sed -i -e 's/target_link_libraries(pcsc INTERFACE'`
		`'/target_link_libraries(${PROJECT_NAME} PUBLIC/' CMakeLists.txt

	# Move flag-set-cpp includes to install/bundle them with libpcsc-cpp
	# headers:
	mv include/flag-set-cpp include/pcsc-cpp/
	sed -i -e 's%/flag-set-cpp/%/${PROJECT_NAME}/flag-set-cpp/%' CMakeLists.txt

	# Use system dev-cpp/magic_enum:
	sed -i -e 's%"magic_enum/magic_enum.hpp"%<magic_enum.hpp>%' src/Reader.cpp
	sed -i -e '/magic_enum\.hpp/d' CMakeLists.txt

	# Use system dev-libs/libpcsc-mock:
	cmake_comment_add_subdirectory tests/lib/libpcsc-mock

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
	doheader -r include/pcsc-cpp
    newlib.so "${BUILD_DIR}"/libpcsc-cpp.so libpcsc-cpp.so
}
