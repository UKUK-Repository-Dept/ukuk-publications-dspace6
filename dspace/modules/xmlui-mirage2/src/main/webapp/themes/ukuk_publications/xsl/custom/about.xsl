<?xml version="1.0" encoding="UTF-8"?>
<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Author: Jakub Řihák (jakub dot rihak at ruk dot cuni dot com)

    XSLT templates related to generation of HTML code for 'about'
    static page.

    On this page, users can find basic information about the repository and submission process.

    Stylesheet is imported in the core/page-structure.xsl. Templates related to
    'typology' page are then called from within the appropriate part of
    core/page-structure.xsl (see <xsl:template match="dri:body"> in core/page-structure.xsl).
-->

<xsl:stylesheet xmlns="http://di.tamu.edu/DRI/1.0/"
                xmlns:dri="http://di.tamu.edu/DRI/1.0/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
                exclude-result-prefixes="xsl dri i18n">

    <xsl:output indent="yes"/>

    <!-- page/about constructor -->
    <xsl:template name="about-create">
        <xsl:call-template name="about-toc-help" />

        <xsl:call-template name="about-intro-text"/>

        <xsl:call-template name="about-typology-availability" />
        
        <xsl:call-template name="about-licensing" />
        
        <xsl:call-template name="about-metadata" />
        
        <xsl:call-template name="about-confirmations" />
        
        <xsl:call-template name="about-workflow" />
    </xsl:template>

    <!-- GENERATE TOC and HELP -->
    <xsl:template name="about-toc-help">
        <div class="row">
            <div class="col-xs-12 col-sm-12 col-md-6" id="about-toc">
                <h2>Obsah</h2>
                <nav>
                    <ul class="list-unstyled">
                        <li role="presentation">
                            <a href="#heading-about-intro-text">Obecné informace</a>
                        </li>
                        <li role="presentation">
                            <a href="#heading-about-typology-availability">Druhy výsledků přijímané do repozitáře</a>
                        </li>
                        <li role="presentation">
                            <a href="#heading-about-licensing">Licencování plných textů uložených a zpřístupněných v repozitáři</a>
                        </li>
                        <li role="presentation">
                            <a href="#heading-about-metadata">Povinné, podmíněně povinné a volitelné popisné údaje výsledku</a>
                        </li>
                        <li role="presentation">
                            <a href="#heading-about-confirmations">Potvrzení prohlášení nutných pro uložení a zpřístupnění plného textu výsledku v repozitáři</a>
                        </li>
                        <li role="presentation">
                            <a href="#heading-about-workflow">Postup uložení a zpřístupnění výsledku v repozitáři</a>
                        </li>
                    </ul>
                </nav>
            </div>
            <div class="col-xs-12 col-sm-12 col-md-6" id="about-help">
                <div class="media">
                    <!-- <div class="media-left"> -->
                    <!-- <a href="#"> -->
                        <!-- <span class="glyphicon glyphicon-info-sign" aria-hidden="true"></span> -->
                        <!-- <img class="media-object" src="..." alt="..."> -->
                    <!-- </a> -->
                    <!-- </div> -->
                    <div class="media-body">
                        <h2 class="media-heading">Potřebujete poradit?</h2>
                        <p>
                            Pokud potřebujete poradit s jakýmkoliv z uvedených témat, neváhejte se obrátit na koordinátora 
                            open access na Vaší součásti. V právních otázkách se obracejte na právníka Centra pro podporu 
                            open science. Všechny kontaktní informace naleznete na webu 
                            <a href="https://openscience.cuni.cz/OSCI-45.html#1" target="_blank">Centra pro podporu open science</a>.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>

    <!-- generate INTRO text -->
    <xsl:template name="about-intro-text">
        <h2 id="heading-about-intro-text">Obecné informace</h2>
        <p>Repozitář publikační činnosti UK slouží jako místo uložení a zpřístupnění plných textů výsledků vědy a výzkumu 
            autorů Univerzity Karlovy. Repozitář je provozován v systému DSpace.
        </p>
        <p>Do repozitáře mohou své výsledky ukládat zaměstnanci i studenti Univerzity Karlovy. Uložení a zpřístupnění výsledku 
            (autoarchivace) v Repozitáři publikační činnosti UK je pro zaměstnance i studenty UK dobrovolná. 
            Proces autoarchivace výsledku v repozitáři je zakotven v 
            <a href="https://cuni.cz/UK-11410.html" target="_blank">opatření rektora č. 40/2021, Evidence tvůrčí činnosti, 
                projektů a zaměstnaneckých mobilit na Univerzitě Karlově</a>.
        </p>
    </xsl:template>

    <!-- GENERATE INFO ON TYPOLOGY and fulltext AVAILABILITY -->
    <xsl:template name="about-typology-availability">
        <h2 id="heading-about-typology-availability">Druhy výsledků přijímané do repozitáře a jejich dostupnost</h2>
        <p>
            Do repozitáře je možné uložit plné texty vybraných druhů výsledků. 
            Seznam druhů výsledků přijímaných do repozitáře je k dispozici na webové stránce 
            <a href="https://publications.cuni.cz/page/typology" target="_blank">Akceptované druhy výsledků</a>. 
        </p>
        <p>
            Plné texty výsledků mohou být v repozitáři zpřístupněny v některém z následujících režimů dostupnosti: 
        </p>
        <div class="table-responsive">
            <table id="about-table-availability" class="table-bordered table-condensed">
                <caption class="sr-only">Tabulka - režimy dostupnosti plného texty výsledku v Repozitáři publikační činnosti</caption>
                <thead>
                    <tr>
                        <th scope="col">režim dostupnosti</th>
                        <th scope="col">popis</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            open access
                        </td>
                        <td>
                            plný text výsledku bude v repozitáři zpřístupněn online pro všechny návštěvníky 
                            repozitáře pod zvolenou licencí 
                        </td>
                    </tr>
                    <tr>
                        <td>
                            open access s embargem
                        </td>
                        <td>
                            plný text výsledku bude v repozitáři zpřístupnění online pro všechny návštěvníky repozitáře 
                            pod zvolenou licení, ale až od určitého nastaveného data (tzv. data ukončení embarga na zpřístupnění) 
                        </td>
                    </tr>
                    <tr>
                        <td>
                            omezená dostupnost
                        </td>
                        <td>
                            plný text výsledku bude v repozitáři zpřístupněn online 
                            pro všechny přihlášené uživatele Univerzity Karlovy
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </xsl:template>

    <!-- GENERATE INFO ABOUT LICENSING -->
    <xsl:template name="about-licensing">
        <h2 id="heading-about-licensing">Licencování plných textů uložených a zpřístupněných v repozitáři</h2>
        <p>Licence uvedená u uloženého plného textu výsledku rozhoduje o rozsahu, 
            ve kterém mohou návštěvníci repozitáře užívat. <b>Byla-li uzavřena licenční smlouva s vydavatelem/nakladatelem, 
            je volba licence v první řadě závislá na podmínkách licenční smlouvy.</b>
        </p>
        <p>
            U plných textů výsledků určené k uložení a zveřejnění v repozitáři lze nastavit 
            jednu z následujících možností jejich licencování:
        </p>
        <div class="table-responsive">
            <table id="about-table-availability" class="table-bordered table-condensed">
                <caption class="sr-only">Tabulka - možnosti licencování plných textů výsledků v Repozitáři publikační činnosti</caption>
                <thead>
                    <tr>
                        <th scope="col">volba licencování</th>
                        <th scope="col">popis</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            bez licence
                        </td>
                        <td>
                            Plný text výsledku bude zveřejněn v repozitáři pouze ke čtení, 
                            tedy v režimu gratis open access. Návštěvníci repozitáře text zveřejněný 
                            bez licence budou moci dále užívat (např. stahovat) pouze se souhlasem vykonavatele 
                            autorských majetkových práv nebo na základě výjimek stanovených zákonem (např. citační licence).
                        </td>
                    </tr>
                    <tr>
                        <td>
                            licence Creative Commons
                        </td>
                        <td>
                            Plný text bude otevřeně přístupný. Záleží na konkrétní licenci, v jakém rozsahu budou moci 
                            uživatelé Váš text užívat. Práva a povinnosti plynoucí z licencí Creative Commons jsou definovány 
                            čtyřmi licenčními prvky (BY, SA, ND, NC). Tyto prvky a jejich kombinace pak tvoří šest variant licencí. 
                            Po výběru konkrétní licence Creative Commons v příslušné verzi z roletky se automaticky vygeneruje URL 
                            odkazující na plný text zvolené licence umístěný na 
                            <a href="https://www.creativecommons.cz/" target="_blank">českých stránkách Creative Commons</a>.
                        </td>
                    </tr>
                    <tr>
                        <td>
                            jiná licence
                        </td>
                        <td>
                            Podmínky licenční smlouvy uzavřené s vydavatelem/nakladatelem ukládají povinnost licencovat plný text 
                            výsledku pod jinou licencí než Creative Commons, zvolte možnost jiné licence. 
                            Tuto možnost můžete zvolit i v případě, kdy žádná licenční smlouva uzavřena nebyla 
                            a o možnostech licencování díla jste oprávněn/a rozhodovat v celé šíři. 
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
        <p>Další, podrobnější informace o variantách Creative Commons licencí najdete na webové stránce 
            <a href="https://publications.cuni.cz/page/licenses" target="_blank">CC Licence</a>.
        </p>
    </xsl:template>

    <!-- GENERATE INFO ABOUT MANDATORY MEDATADA -->
    <xsl:template name="about-metadata">
        <h2 id="heading-about-metadata">Povinné, podmíněně povinné a volitelné popisné údaje výsledku</h2>
        <p>
            Pro účely uložení a zpřístupnění výsledku v repozitáři publikační činnosti UK vyžadujeme 
            sadu povinných a tzv. podmíněně povinných popisných údajů. Oba dva typy těchto popisných 
            údajů jsou povinné, ale v případě podmíněně povinných údajů lze při jejich vyplňování 
            (a následné kontrole) brát v potaz, zda daný údaj je možné zjistit či získat pro danou 
            formu výsledku nebo pro aktuální stav publikace výsledku.
        </p>
        <p>
            Kromě povinných a podmíněně povinných popisných údajů výsledku je v modulu OBD IS Věda 
            možné vyplnit také další, z hlediska uložení a zpřístupnění v repozitáři volitelné, 
            popisné údaje. Vyplnění a správnost těchto nepovinných údajů není před přijetím výsledku 
            do repozitáře kontrolováno. 
        </p>
        <p>
            Vyplnění volitelných údajů ale umožňuje například:
        </p>
        <ul>
            <li>zobrazovat doplňující informace v náhledu záznamu výsledku v repozitáři</li>
            <li>zvýšit pravděpodobnost vyhledání relevantních výsledku v repozitáři</li>
            <li>generovat bibliografické citace k výsledkům uloženým v repozitáři</li>
            <li>zajišťovat shromažďování dodatečných statistických informací o výsledku uloženém v repozitáři</li>
        </ul>
        <p>
            Podrobnější informace o povinných a podmíněně povinných popisných údajích najdete na webové 
            stránce <a href="https://publications.cuni.cz/page/metadata" target="_blank">Povinné popisné údaje</a>.
        </p>
    </xsl:template>

    <xsl:template name="about-confirmations">
        <h2 id="heading-about-confirmations">Potvrzení prohlášení nutných pro uložení a zpřístupnění plného textu výsledku v repozitáři</h2>
        <p>
            Nutným krokem pro uložení a zpřístupnění plného textu výsledku je rovněž potvrzení, že s uložením 
            a zpřístupněním příslušné verze plného textu v repozitáři souhlasí všichni spoluautoři 
            a že tímto nedochází k porušení práv vydavatele/nakladatele či jiné třetí strany. 
            Potvrzení těchto skutečností provedete prostřednictvím příslušného zaškrtávacího pole 
            v záznamu výsledku v modulu OBD IS Věda.
        </p>
        <p>
            Zaškrtnutí prohlášení o souhlasu spoluautorů s uložením a zpřístupněním plného textu výsledku 
            v repozitáři je nutné i v případě, že má výsledek pouze jediného autora 
            (jde o nutnou technickou podmínku přenosu do repozitáře). 
        </p>
        <p>
            Celý text obou prohlášení je následující:
        </p>
        <div class="table-responsive">
            <table id="about-table-confirmations" class="table-bordered table-condensed">
                <caption class="sr-only">Tabulka - texty prohlášení</caption>
                <thead>
                    <tr>
                        <th scope="col">prohlášení</th>
                        <th scope="col">celý text</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            Potvrzení o souhlasu spoluautorů
                        </td>
                        <td>
                            <i>
                                Prohlašuji, že mám souhlas od všech spoluautorů s uložením a zpřístupněním 
                                přiloženého plného textu díla v repozitáři publikační činnosti UK.
                            </i>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Potvrzení o nezasahování do práv vydavatele/nakladatele či jiné třetí strany
                        </td>
                        <td>
                            <i>
                                Prohlašuji, že uložením a zpřístupněním souboru v repozitáři publikační 
                                činnosti UK nebudou narušená práva vydavatele/nakladatele či jiné třetí strany.
                            </i> 
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
        <p>
            Pokud prohlášení nebudou potvrzena, výsledek nebude uložen a zpřístupněn v repozitáři a zůstane uložen 
            pouze v modulu OBD IS Věda. Detailní poučení vztahující se k výše uvedeným potvrzením je dostupné na 
            webové stránce <a href="https://topi.is.cuni.cz/page/disclaimer" target="_blank">Poučení</a>.
        </p>
    </xsl:template>

    <!-- GENERATE INFO ABOUT WORKFLOW -->
    <xsl:template name="about-workflow">
        <h2>Postup uložení a zpřístupnění výsledku v repozitáři</h2>
        <p>Ve stručnosti lze kroky shrnout následovně:</p>
        <div class="table-responsive">
            <table id="about-table-workflow" class="table table-condensed">
                <caption class="sr-only">Postup uložení a zpřístupnění výsledku v repozitáři</caption>
                <thead>
                    <tr>
                        <th>pořadí</th>
                        <th>popis kroku</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            Krok 1
                        </td>
                        <td>
                            Zkontrolujte, že výsledek je s ohledem na jeho druh možné uložit a zpřístupnit v repozitáři, 
                            viz <a href="https://publications.cuni.cz/page/typology" target="_blank">seznam druhů výsledků přijímaných do repozitáře</a>.
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Krok 2
                        </td>
                        <td>
                            Zkontrolujte licenční smlouvu uzavřenou s vydavatelem/nakladatelem (pokud je výsledek již vydaný 
                            nebo je v budoucnu plánováno jeho vydání) a ujistěte se, že je možné výsledek uložit a zpřístupnit 
                            v repozitáři a za jakých podmínek.
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Krok 3
                        </td>
                        <td>
                            Jste-li autorem, zajistěte si souhlasy případných spoluautorů výsledku s uložením a zveřejněním 
                            plného textu výsledku v repozitáři, případně ověřte, že autor souhlasy disponuje.
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Krok 4
                        </td>
                        <td>
                            Přihlaste se do modulu OBD IS Věda a založte nový záznam nebo editujte záznam existující.
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Krok 5
                        </td>
                        <td>
                            Vyplňte všechny povinné i relevantní podmíněně povinné údaje o výsledku 
                            nebo zkontrolujte jejich aktuálnost a správnost, pokud jsou již vyplněny.
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Krok 6
                        </td>
                        <td>
                            Vložte plný text výsledku určený pro uložení a zpřístupnění v repozitáři do 
                            příslušné části formuláře záznamu výsledku v OBD.
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Krok 7
                        </td>
                        <td>
                            Vyberte verzi vloženého souboru plného textu výsledku a variantu jeho zpřístupnění v repozitáři.
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Krok 8
                        </td>
                        <td>
                            (Volitelně) vložte do příslušné části formuláře záznamu výsledku v OBD další soubory 
                            (např. licenční smlouvu uzavřenou s vydavatelem/nakladatelem).
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Krok 9
                        </td>
                        <td>
                            Potvrďte zaškrtnutím příslušných polí v záznamu výsledku v OBD u vloženého plného textu, že:
                            <ul>
                                <li>uložením a zpřístupněním plného textu výsledku neporušujete práva 
                                    vydavatele/nakladatele či jiné třetí strany;
                                </li>
                                <li>
                                    disponujete souhlasem všech spoluautorů výsledku s uložením a zveřejněním jeho 
                                    plného textu v repozitáři.
                                </li>
                            </ul>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Krok 10
                        </td>
                        <td>
                            Uložte záznam výsledku.
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
        <p>
            Po provedení výše uvedených kroků je záznam výsledku i s přiloženým plným textem zkontrolován 
            fakultním koordinátorem open access. Po schválení ze strany fakultního koordinátora open access 
            je pak výsledek, včetně přiloženého plného textu, přenesen z modulu OBD IS Věda automaticky 
            do tohoto repozitáře. 
        </p>
        <p>
            Schválený a úspěšně přenesený výsledek bude mít v repozitáři vytvořen samostatný záznam pro 
            každou z verzí přiloženého plného textu.
        </p>
        <p>
            Na záznam výsledku v repozitáři je možné odkazovat pomocí trvalého odkazu uvedeného v poli 
            <i>Trvalý odkaz</i> záznamu výsledku v repozitáři. Systém repozitáře využívá pro tvorbu 
            a udržování trvalých odkazů službu HANDLE Resolver a každý z výsledků má přidělen unikátní 
            HANDLE identifikátor, který je součásti trvalého odkazu. Tento identifikátor je výsledku 
            přidělen v okamžiku jeho prvního přenosu do repozitáře a zůstává v platnosti i v případě 
            následných aktualizací záznamu.
        </p>
    </xsl:template>

</xsl:stylesheet>