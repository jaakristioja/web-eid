#
# Copyright (c) 2023 Jaak Ristioja
#
# SPDX-License-Identifier: MIT
#

EAPI=8

inherit cmake

DESCRIPTION="C++ library for mocking responses to PC/SC smart card API function calls."
HOMEPAGE="https://github.com/web-eid/libpcsc-mock"
SRC_URI="https://github.com/web-eid/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

RESTRICT="!test? ( test )"

DEPEND="${RDEPEND}
	sys-apps/pcsc-lite
	virtual/pkgconfig
	test? ( dev-cpp/gtest )
"

PATCHES=(
	"${FILESDIR}"/${P}-tests-optional.patch
)

src_prepare() {
	# Build a shared library instead of static library:
	sed -i -e 's/STATIC/SHARED/' CMakeLists.txt

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
	doheader -r include/pcsc-mock
	newlib.so "${BUILD_DIR}"/libpcsc-mock.so libpcsc-mock.so
}
