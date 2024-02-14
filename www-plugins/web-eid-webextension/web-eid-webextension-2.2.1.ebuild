#
# Copyright (c) 2024 Jaak Ristioja
#
# SPDX-License-Identifier: MIT
#

EAPI=8

DESCRIPTION="The Web eID browser extension for Mozilla Firefox"
HOMEPAGE="https://addons.mozilla.org/en-US/firefox/addon/web-eid-webextension/"
SRC_URI="https://addons.mozilla.org/firefox/downloads/latest/${PN}/${PN//-/_}-${PV}.xpi"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

S="${WORKDIR}"

src_install() {
	insinto '/usr/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}'
	newins "${DISTDIR}/${PN//-/_}-${PV}.xpi" \
		'{e68418bc-f2b0-4459-a9ea-3e72b6751b07}.xpi'
}
