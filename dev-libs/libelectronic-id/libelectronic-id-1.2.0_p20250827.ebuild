#
# Copyright (c) 2023 Jaak Ristioja
#
# SPDX-License-Identifier: MIT
#

EAPI=8

inherit cmake

GIT_REV='dfb29b8eef499507b5ea9858ea61a835e48bf308'
DESCRIPTION="C++ library for performing cryptographic operations with electronic identification (eID) cards."
HOMEPAGE="https://github.com/web-eid/libelectronic-id"
SRC_URI="https://github.com/web-eid/${PN}/archive/${GIT_REV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

RESTRICT="!test? ( test )"

RDEPEND="
	sys-apps/pcsc-lite
"

DEPEND="${RDEPEND}
	>=dev-libs/openssl-3.0.0
	test? (
		dev-cpp/gtest
	)
"

PATCHES=(
	"${FILESDIR}"/${P}-disable-system-integration-tests.patch
	"${FILESDIR}"/${P}-tests-optional.patch
)

S="${WORKDIR}/${PN}-${GIT_REV}"

src_prepare() {
	# Build a shared libraries instead of static libraries:
	sed -i -e 's/STATIC/SHARED/' \
		CMakeLists.txt \
		lib/libpcsc-cpp/CMakeLists.txt

	# Fix linking with libpcsclite:
	echo 'target_link_libraries(${PROJECT_NAME} PUBLIC pcsc)' >> \
		lib/libpcsc-cpp/CMakeLists.txt

	# Use system dev-cpp/magic_enum:
	sed -i -e 's%"magic_enum/magic_enum.hpp"%<magic_enum/magic_enum.hpp>%' \
		src/electronic-id.cpp

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test)
		-DCMAKE_CXX_STANDARD=20
		-DCMAKE_POSITION_INDEPENDENT_CODE=ON
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

	newdoc lib/libpcsc-cpp/LICENSE LICENSE-libpcsc-cpp
	newdoc lib/libpcsc-cpp/README.md README-libpcsc-cpp.md
	doheader -r lib/libpcsc-cpp/include/pcsc-cpp
	newlib.so "${BUILD_DIR}"/lib/libpcsc-cpp/libpcsc-cpp.so libpcsc-cpp.so
}
