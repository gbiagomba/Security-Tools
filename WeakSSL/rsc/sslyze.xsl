<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="html" version="1.0" encoding="utf-8" indent="yes"/>

  <xsl:variable name="relationship">
    <full key="host" value="Hostname"/>
    <full key="ip" value="IP Address"/>
    <full key="port" value="Port"/>

    <full key="commonName" value="Common Name"/>
    <full key="notBefore" value="Not Before"/>
    <full key="notAfter" value="Not After"/>
    <full key="signatureAlgorithm" value="Signature Algorithm"/>
    <full key="publicKeyAlgorithm" value="Public Key Algorithm"/>
    <full key="publicKeySize" value="Key Size"/>
    <full key="exponent" value="Exponent"/>

    <short key="organizationalUnitName" value="OU"/>
    <short key="organizationName" value="O"/>
    <short key="commonName" value="CN"/>
    <short key="stateOrProvinceName" value="ST"/>
    <short key="countryName" value="C"/>
    <short key="localityName" value="L"/>

    <full key="sslv2" value="SSL 2.0"/>
    <full key="sslv3" value="SSL 3.0"/>
    <full key="tlsv1" value="TLS 1.0"/>
    <full key="tlsv1_1" value="TLS 1.1"/>
    <full key="tlsv1_2" value="TLS 1.2"/>

    <full key="reneg" value="Session Renegotiation"/>
    <full key="resum" value="Session Resumption"/>
    <full key="compression" value="Deflate Compression"/>
    <full key="heartbleed" value="OpenSSL Heartbleed"/>
  </xsl:variable>

  <xsl:key name="FullName" match="full" use="@key"/>
  <xsl:key name="ShortName" match="short" use="@key"/>

  <xsl:template name="fullname">
      <xsl:param name="key"/>
      <xsl:for-each select="document('')">
          <xsl:value-of select="key('FullName', $key)/@value"/>
      </xsl:for-each>
  </xsl:template>

  <xsl:template name="shortname">
      <xsl:param name="key"/>
      <xsl:for-each select="document('')">
          <xsl:value-of select="key('ShortName', $key)/@value"/>
      </xsl:for-each>
  </xsl:template>

  <xsl:template match="/document/results/target">
    <html>
      <head>
        <title> SSL Check </title>
        <link media="all" rel="stylesheet" type="text/css" href="https://sslcheck.globalsign.com/stylesheets/all-ssl-config.css"/>
      </head>
      <body class="sub-inner-page">
        <div id="wrapper">
          <div class="sub-inner">
            <div class="sub-inner-w1">
              <div class="sub-inner-w2">
                <div class="sub-inner-w3">
                  <div class="details-block">

                    <a id="server" href="#" class="detail-drawer-tab active">
                      <h3> Server Details </h3>
                    </a>
                    <div style="display: block;" class="detail-drawer server-drawer">
                      <div class="drawer-image-holder">Server Details Icon</div>
                      <div class="drawer-info-holder">
                        <xsl:call-template name="basic-info-block">
                          <xsl:with-param name="node" select="@host"/>
                        </xsl:call-template>
                        <xsl:call-template name="basic-info-block">
                          <xsl:with-param name="node" select="@ip"/>
                        </xsl:call-template>
                        <xsl:call-template name="basic-info-block">
                          <xsl:with-param name="node" select="@port"/>
                        </xsl:call-template>
                      </div>
                    </div>

                    <a id="cert" href="#" class="detail-drawer-tab active">
                      <h3>Certificate Details</h3>
                    </a>
                    <div style="display: block;" class="detail-drawer certificate-drawer">
                      <div class="drawer-image-holder">Certificate Details Icon</div>
                      <div class="drawer-info-holder">
                        <xsl:apply-templates select="certinfo/certificateChain"/>
                        <xsl:apply-templates select="certinfo/ocspStapling"/>
                        <xsl:apply-templates select="certinfo/certificateValidation"/>
                      </div>
                    </div>

                    <a id="chiper" href="#" class="detail-drawer-tab active">
                      <h3>Cipher Suites</h3>
                    </a>
                    <div style="display: block;" class="detail-drawer ssl-drawer">
                      <div class="drawer-image-holder">SSL Configuration Icon</div>
                      <div class="drawer-info-holder">
                        <div class="info-block">
                          <strong class="info-category"> Protocol: </strong>
                          <strong class="info-category ssl-supported"> Supported: </strong>
                        </div>
                        <xsl:apply-templates select="(sslv2 | sslv3 | tlsv1 | tlsv1_1 | tlsv1_2)/@isProtocolSupported"/>
                      </div>
                      <div class="cipher-drawer">
                        <div class="drawer-image-holder">Cipher Suites Icon</div>
                        <div class="drawer-info-holder">
                          <xsl:apply-templates select="sslv2 | sslv3 | tlsv1 | tlsv1_1 | tlsv1_2"/>
                        </div>
                      </div>
                    </div>

                    <a id="misc" href="#" class="detail-drawer-tab active">
                      <h3> Miscellaneous Details </h3>
                    </a>
                    <div style="display: block;" class="detail-drawer">
                      <div class="drawer-image-holder">Miscellaneous Details Icon</div>
                      <div class="drawer-info-holder">
                        <xsl:apply-templates select="compression | heartbleed | reneg | resum"/>
                      </div>
                    </div>

                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="/target">
    <xsl:call-template name="basic-info-block">
      <xsl:with-param name="node" select="@host"/>
    </xsl:call-template>
    <xsl:call-template name="basic-info-block">
      <xsl:with-param name="node" select="@ip"/>
    </xsl:call-template>
    <xsl:call-template name="basic-info-block">
      <xsl:with-param name="node" select="@port"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="basic-info-block">
    <xsl:param name="node"/>
    <xsl:param name="addition" select="''" />
    <div class="info-block {$addition}">
      <strong class="info-category">
        <xsl:call-template name="fullname">
          <xsl:with-param name="key" select="name($node)"/>
        </xsl:call-template>
      </strong>
      <span class="data">
        <xsl:value-of select="$node"/>
      </span>
    </div>
  </xsl:template>

  <xsl:template match="sslv2 | sslv3 | tlsv1 | tlsv1_1 | tlsv1_2">
    <xsl:if test="@isProtocolSupported = 'True'">
      <div class="info-block">
        <strong class="info-category section"> <xsl:value-of select="@title"/> </strong>
        <strong class="info-category strength">Effective Strength:</strong>
        <xsl:apply-templates select="acceptedCipherSuites" />
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="cipherSuite">
    <div class="info-block">
      <xsl:apply-templates select="@name"/>
      <xsl:apply-templates select="@keySize"/>
    </div>
  </xsl:template>

  <xsl:template match="cipherSuite/@name">
    <span class="protocol-type">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template match="cipherSuite/@keySize">
    <xsl:choose>
      <xsl:when test=". &gt;= 128">
        <span class="data neutral">
          <xsl:value-of select="."/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <span class="data bad">
          <xsl:value-of select="."/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@isProtocolSupported">
    <div class="info-block">
      <span class="protocol-type"> 
        <xsl:call-template name="fullname">
          <xsl:with-param name="key" select="name(..)"/>
        </xsl:call-template>
      </span>
      <xsl:choose>
        <xsl:when test="(starts-with(name(..),'ssl') and .='False') or (starts-with(name(..),'tls') and .='True')">
          <span class="data good">
            <xsl:value-of select="."/>
          </span>
        </xsl:when>
        <xsl:otherwise>
          <span class="data bad">
            <xsl:value-of select="."/>
          </span>
          <xsl:choose>
            <xsl:when test="name(..) = 'sslv2'">
              <xsl:call-template name="tooltip">
                <xsl:with-param name="tipstr" select="'SSL v2 should be disabled as it has known security issues'"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="name(..) = 'sslv3'">
              <xsl:call-template name="tooltip">
                <xsl:with-param name="tipstr" select="'SSL v3 should be disabled if compatibility with older mobile clients is not required'"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="name(..) = 'tlsv1'">
              <xsl:call-template name="tooltip">
                <xsl:with-param name="tipstr" select="'TLS v1.0 should be enabled for optimum compatibility'"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="name(..) = 'tlsv1_1' or name(..) = 'tlsv1_2'">
              <xsl:call-template name="tooltip">
                <xsl:with-param name="tipstr" select="'Server should enable more recent versions of TLS protocol'"/>
              </xsl:call-template>
            </xsl:when>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template match="certificateChain">
    <xsl:call-template name="basic-info-block">
      <xsl:with-param name="node" select="certificate/subject/commonName"/>
    </xsl:call-template>
    <xsl:call-template name="basic-info-block">
      <xsl:with-param name="node" select="certificate/validity/notBefore"/>
    </xsl:call-template>
    <xsl:call-template name="basic-info-block">
      <xsl:with-param name="node" select="certificate/validity/notAfter"/>
    </xsl:call-template>
    <xsl:call-template name="basic-info-block">
      <xsl:with-param name="node" select="certificate/signatureAlgorithm"/>
    </xsl:call-template>
    <xsl:call-template name="basic-info-block">
      <xsl:with-param name="node" select="certificate/subjectPublicKeyInfo/publicKeyAlgorithm"/>
    </xsl:call-template>
    <xsl:call-template name="basic-info-block">
      <xsl:with-param name="node" select="certificate/subjectPublicKeyInfo/publicKeySize"/>
    </xsl:call-template>
    <xsl:call-template name="basic-info-block">
      <xsl:with-param name="node" select="certificate/subjectPublicKeyInfo/publicKey/exponent"/>
      <xsl:with-param name="addition" select="'border-split'"/>
    </xsl:call-template>

    <div class="certificate-no-chain-block">
      <div class="drawer-info-holder">
        <div class="info-block">
          <strong class="info-category"> Certificates </strong>
        </div>
        <xsl:apply-templates select="certificate"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="ocspStapling">
    <div class="grid">
      <div class="info-block">
        <strong class="info-category section">
          OCSP Stapling
        </strong>
        <div class="info-block">
          <strong class="grid-data"> Supported </strong>
          <span class="pass-fail good">
            <xsl:value-of select="@isSupported"/>
          </span>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="certificateValidation">
    <div class="grid">
      <div class="info-block">
        <strong class="info-category section">
          Certificate Validation
        </strong>
        <div class="info-block">
          <xsl:for-each select="pathValidation">
            <strong class="grid-data">
              <xsl:value-of select="concat(concat(@usingTrustStore,'  '),@trustStoreVersion)"/>
            </strong>
            <xsl:choose>
              <xsl:when test="@validationResult = 'ok'">
                <span class="pass-fail good">
                  <xsl:value-of select="@validationResult"/>
                </span>
              </xsl:when>
              <xsl:otherwise>
                <span class="pass-fail bad">
                  error
                </span>
                <xsl:choose>
                  <xsl:when test="@error">
                    <xsl:call-template name="tooltip">
                      <xsl:with-param name="tipstr" select="@error"/>
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:call-template name="tooltip">
                      <xsl:with-param name="tipstr" select="@validationResult"/>
                    </xsl:call-template>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="certificate">
    <div class="certificate-info-block">
      <div class="certificate-info-holder">
        <img src="https://sslcheck.globalsign.com/images/cert-icon.gif" alt="Server Certificate image" height="67" width="73"></img>
        <div class="certificate-content">
          <div class="content-block subject">
            <div class="content-type"> Subject: </div>
            <ul class="certificate-data-content">
              <xsl:apply-templates select="subject/organizationalUnitName"/>
              <xsl:apply-templates select="subject/organizationName"/>
              <xsl:apply-templates select="subject/commonName"/>
              <xsl:apply-templates select="subject/stateOrProvinceName"/>
              <xsl:apply-templates select="subject/countryName"/>
              <xsl:apply-templates select="subject/localityName"/>
            </ul>
          </div>
          <div class="content-block issuer">
            <div class="content-type"> Issuer: </div>
            <ul class="certificate-data-content">
              <xsl:apply-templates select="issuer/organizationalUnitName"/>
              <xsl:apply-templates select="issuer/organizationName"/>
              <xsl:apply-templates select="issuer/commonName"/>
              <xsl:apply-templates select="issuer/stateOrProvinceName"/>
              <xsl:apply-templates select="issuer/countryName"/>
              <xsl:apply-templates select="issuer/localityName"/>
            </ul>
          </div>
          <div class="content-block expiry">
            <div class="content-type"> Expiration Date: </div>
            <div class="cert-data">
                  <xsl:value-of select="validity/notAfter"/>
            </div>
          </div>
          <div class="content-block last">
            <ul class="certificate-last-info">
              <li>
                <div class="content-type"> Serial Number </div>
                <div class="cert-data">
                  <xsl:value-of select="serialNumber"/>
                </div>
              </li>
              <li>
                <div class="content-type"> Fingerprint (SHA-1): </div>
                <div class="cert-data">
                  <xsl:value-of select="@sha1Fingerprint"/>
                </div>
              </li>
            </ul>
          </div>
          <a href="data:application/x-pem-file,{asPEM}" download="{serialNumber}.pem" class="download-link">
            Download Certificate
          </a>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="subject/* | issuer/*">
    <li>
        <span class="certificate-data-category">
          <xsl:call-template name="shortname">
            <xsl:with-param name="key" select="name()"/>
          </xsl:call-template>
        </span>
        <span class="content">
          <xsl:value-of select="."/>
        </span>
    </li>
  </xsl:template>

  <xsl:template match="compression | heartbleed | reneg | resum">
    <div class="grid">
      <div class="info-block">
        <strong class="info-category section">
        <xsl:call-template name="fullname">
          <xsl:with-param name="key" select="name()"/>
        </xsl:call-template>
        </strong>
        <div class="info-block">
            <xsl:choose>
              <xsl:when test="@exception">
                <strong class="grid-data"> 
                  <xsl:value-of select="@exception"/>
                </strong>
                <span class="pass-fail bad">
                  Error
                </span>
              </xsl:when>
              <xsl:otherwise>
                <xsl:for-each select="*">
                  <xsl:apply-templates select="."/>
                </xsl:for-each>
              </xsl:otherwise>
            </xsl:choose>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="compression/compressionMethod">
    <strong class="grid-data"> Supports Deflate compression </strong>
    <xsl:choose>
      <xsl:when test="@isSupported != 'True'">
        <span class="pass-fail good">
          <xsl:value-of select="@isSupported"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <span class="pass-fail bad">
          <xsl:value-of select="@isSupported"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="heartbleed/openSslHeartbleed">
    <strong class="grid-data"> Vulnerable to Heartbleed </strong>
    <xsl:choose>
      <xsl:when test="@isVulnerable != 'True'">
        <span class="pass-fail good">
          <xsl:value-of select="@isVulnerable"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <span class="pass-fail bad">
          <xsl:value-of select="@isVulnerable"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="reneg/sessionRenegotiation">
    <strong class="grid-data"> Secure Renegotiation (Client-Initiated) </strong>
    <xsl:choose>
      <xsl:when test="@canBeClientInitiated != 'True'">
        <span class="pass-fail good">
          <xsl:value-of select="@canBeClientInitiated"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <span class="pass-fail bad">
          <xsl:value-of select="@canBeClientInitiated"/>
        </span>
        <xsl:call-template name="tooltip">
          <xsl:with-param name="tipstr" select="'Client-initiated renegotiation should be disabled'"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <strong class="grid-data"> Secure Renegotiation (Server-Initiated) </strong>
    <xsl:choose>
      <xsl:when test="@isSecure != 'False'">
        <span class="pass-fail good">
          <xsl:value-of select="@isSecure "/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <span class="pass-fail bad">
          <xsl:value-of select="@isSecure "/>
        </span>
        <xsl:call-template name="tooltip">
          <xsl:with-param name="tipstr" select="'Secure server-initiated renegotiation should be enabled'"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="resum/sessionResumptionWithSessionIDs">
    <strong class="grid-data"> With Session IDs </strong>
    <span class="pass-fail good">
      <xsl:value-of select="@isSupported"/>
    </span>
  </xsl:template>

  <xsl:template match="resum/sessionResumptionWithTLSTickets">
    <strong class="grid-data"> With TLS Session Tickets </strong>
      <span class="pass-fail good">
        <xsl:value-of select="@isSupported"/>
      </span>
  </xsl:template>

  <xsl:template name="tooltip">
    <xsl:param name="tipstr"/>
      <a class="tooltip-link overflow">
        <span class="tooltip">
          <span class="tooltip-holder">
              <xsl:value-of select="$tipstr" />
            <span class="arrow">arrow</span>
          </span>
        </span>
      </a>
  </xsl:template>

</xsl:stylesheet>
