import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sheikh.dart';

class SheikhBiographyScreen extends StatelessWidget {
  final Sheikh singleSheikh = Sheikh(
    name: 'Sheikh Adamu Tsoho Ahmad Jos',
    imageUrl: 'assets/bio.jpg', // You can also use 'assets/4.jpg' if bio.jpg is missing
    shortBio: 'Takaitaccen Tarihin Sheikh Adamu Tsoho Ahmad Jos',
    fullBio: '''An haifi Sheikh Adamu Tsoho Ahmad 21/02/1960 - 24/08/1379AH. ya rasu ranar 30/07/2024 - 24/01/1446AH. Shi dai Sheikh Adamu Tsoho ɗan garin Jos ne ta jihar Filato. Mahaifinsa Sunansa Malam Muhammad Sani, amma an fi kiransa da Tsoho, kakansa kuma Malam Ahmad Kiffa, wanda yana daya daga cikin mutane 14 da aka kwaso su daga Bauchi a wancan lokacin aka kawo su Jos da nufin su raya garin na Jos. Kamar yadda Mahaifin Shaikh din ya tabbatar mana a wani hira da aka taba yi da shi a kan tarihin kafa garin Jos a kwanakin baya. Mahaifiyar Shaikh Adamu Tsoho kuwa sunanta Hajiya Amina, ba a fi shekaru 12 ba da Allah Ya mata rasuwa ba.

A yayin da su goma(10) ne a wajen mahaifinsu, sai dai mahaifin nasu ya tabbatar da cewa Shaikh Adamu Tsoho na daban ne a cikin `ya`yan nasa ta fuskacin tsayuwa da addini da kuma kula da hakkinsu na Iyaye. Shaikh Adamu Tsoho ya yi karatun Allo kamar yadda aka saba, a wata makarantar Allo da ake cewa Makarantar Alaramma a garin Jos, a lokaci guda kuma yana hadawa da karatun Islamiyya a wata shahararriyar makarantar dare da ake cewa `Misbahudden` a wancan lokacin. Ya kasance mai hazaka sosai, har ma ya zama lokacin da Shaikh Ibrahim Nyass (RA) ya zo Nijeriya, Shaikh Adamu Tsoho na daga cikin hazikan yara guda bakwai da aka zaba daga Islamiyyar tasu suka je don su rairawa Shehu baitocin wake da larabci, nan Shehu ya karbe su da wakokin yabon Annabi (S), kuma ya yi musu addu`o`i.

Shaikh Adamu Tsoho har ila yau, ya yi makarantar Nizamiyya, wacce ake kiranta da Islamiyya School. A wannan School din, ana karatun boko ne da na addini, amma tana matsayin Primary ne a lokacin. Har ma Mahaifin Shaikh din, ya shaida min cewa a cikin yayansa goma, duk da akwai yayyin Malam Adamu, amma shine aka fara sakawa a makarantar boko ta Nizamiyya. Saboda yadda ake gudun boko a da, amma da wani abu ya faru, sai ya nemi izinin kakan Malam Adamu din ya nemi a bari a saka shi a fara gwaji da shi. Mahaifin Shaikh Adamu Tsoho yace; "Alhamdulillahi, sai muka ga kuma yayin da Bokon nasa tai nisa kawai ya tsinci kansa a harkokin addinin Musulunci, har ma muka ga bayan da suka tafi boko a wasu garin, in sun dawo daga makaranta suna shirya karatuttukan addini don ilmantar da matasa (Ta`alimi), kai hatta Ittikafi da ake yi a karshen Azumi, an dade muna karantawa ne a littafi, su Malam Adamu ne suka fara yin Ittikafi a Masallacin garin nan na Jos sannan mutane suka amsa."

Bayan gama Islamiyya, Shaikh Adamu Tsoho Ahmad ya tafi karamar makarantar Sakandire a Bauchi, daga baya ya dawo GSS Gumau ya kammala junior din, ya kuma kammala sakandiren a Science School Toro duk a Jihar ta Bauchi. Bayan gama Sakandire a shekarar 1982, ne ya tafi ABU da nufin sharar fagen shiga Jami`a, wanda kamar yadda na ambata a tarihin Shaikh Mukhtar Sahabi, bayan wasu abubuwa da suka faru, sakamakon tsayuwa da matsayarsu akan addini aka kore su daga makarantar. Sannan suka koma Poly a Kaduna, wacce ita ma harkokin gwagwarmaya ya sabbaba rashin gamawarsu a nan. Dole ya hakura, har sai daga baya sosai sannan ya je Jami`ar Bayero a garin Kano, inda ya karanta `Arabic and Mass Communication` a digirinsa.

Tun Shaikh Adamu Tsoho suna Secondary suka hadu da Shaikh Zakzaky (H), gabanin ayyana Harka Islamiyya a sarari (kafin Funtua Declaration) a yayin da su Malam (H) su ke bin garuruwa ana shiryawa dalibai IVC a karkashin inuwar MSS. Shaikh Adamu ya taba bamu labarin ganin farko da ya wa Shaikh Zakzaky yana tunanin a garin Makodi ne, ana taron IVC, ya gansu suna Sallah da daddare a masallaci, sai ya yi alwala ya shiga masallacin shima ya fara. Ko da yake bayan wannan sun cigaba da zuwa suna wa Malam tambayoyi, saboda a lokacin duk inda aka je IVC, a kan raba ajujuwa ne, to mutane kowa ya kan fi so a saka shi a ajin da Malam Zakzaky ke karantarwa.

Bayan fitowar Shaikh Zakzaky daga Kurkukun Shagari a shekarar 1984 ne Shaikh Adamu Tsoho suka tashi shi da wani musamman suka zo Zariya wajen Shaikh Zakzaky (H), suka masa jaje, sannan suka jaddada bai`a gare su gaba-da-gaba. Yace: "A lokacin da muka je, sai su Malam suka ce mana ba matsala da hakan, amma dai ita Harka din nan aiki ne kawai mutum zai tsayu da shi har karshen rayuwarsa." Malam yai musu nasihohi suka tafi. Tun daga wannan lokacin suka tsayu da Harka a rayuwarsu har zuwa sanda nauyi (mas`uliyya) suka hau kansu, kuma Alhamdulillahi har yau suna nan ana Harka tare da su.''',
  );

  SheikhBiographyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF9F9F9);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1A1A1A);
    final secondaryTextColor = isDarkMode ? Colors.white70 : const Color(0xFF4A4A4A);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350.0,
            pinned: true,
            backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
            iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black87),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/4.jpg', // Main beautiful picture
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF9F9F9),
                        ],
                        stops: const [0.5, 0.8, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tarihin Rayuwar',
                    style: GoogleFonts.lora(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    singleSheikh.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Quote Block
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border(
                        left: BorderSide(
                          color: Colors.cyanAccent[400] ?? Colors.cyan,
                          width: 4,
                        ),
                      ),
                    ),
                    child: Text(
                      singleSheikh.shortBio,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Main Body
                  ...singleSheikh.fullBio.split('\n\n').map((paragraph) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        paragraph,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: secondaryTextColor,
                          height: 1.8,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    );
                  }).toList(),
                  
                  const SizedBox(height: 40),
                  Center(
                    child: Icon(
                      Icons.spa_rounded,
                      color: Colors.cyanAccent[400]?.withOpacity(0.5),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
