import '../domain/game_contract/game_controller.dart';
import '../domain/models/challenge.dart';
import '../domain/models/profile.dart';
import 'modules/g001_number_pebble_circle/g001_controller.dart';
import 'modules/g002_count_orchard/g002_controller.dart';
import 'modules/g011_find_the_letter/g011_controller.dart';
import 'modules/g021_picture_word_search/g021_controller.dart';
import 'modules/g031_shape_home/g031_controller.dart';
import 'modules/g041_picture_pair_memory/g041_controller.dart';
import 'modules/g051_animal_jigsaw/g051_controller.dart';
import 'modules/g061_pattern_path/g061_controller.dart';
import 'modules/g012_alpha_grid_tap/g012_controller.dart';
import 'modules/g072_word_builder/g072_controller.dart';
import 'modules/g073_spelling_puzzle/g073_controller.dart';
import 'modules/g074_kid_math/g074_controller.dart';
import 'modules/g075_pattern_sequence/g075_controller.dart';
import 'modules/g076_animal_sounds/g076_controller.dart';
import 'modules/g077_animal_quiz/g077_controller.dart';
import 'modules/g078_rhyming_words/g078_controller.dart';
import 'modules/g079_letter_tracing/g079_controller.dart';
import 'modules/g080_musical_xylophone/g080_controller.dart';
import 'modules/g081_sorting_factory/g081_controller.dart';
import 'modules/g082_habitat_match/g082_controller.dart';
import 'modules/g083_color_mixing_lab/g083_controller.dart';
import 'modules/g084_toothbrush_hero/g084_controller.dart';
import 'modules/g085_detective_leo/g085_controller.dart';
import 'modules/g086_space_explorer/g086_controller.dart';
import 'modules/g087_feeling_mirror/g087_controller.dart';
import 'modules/g088_dino_bone_digger/g088_controller.dart';
import 'modules/g089_balloon_fiesta/g089_controller.dart';
import 'modules/g090_size_stacker/g090_controller.dart';

class GameFactory {
  static GameController createController({
    required Challenge challenge,
    required Profile profile,
    required int seed,
  }) {
    switch (challenge.gameId) {
      case 'G001':
        return G001Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G002':
        return G002Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G011':
        return G011Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G021':
        return G021Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G031':
        return G031Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G041':
        return G041Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G051':
        return G051Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G061':
        return G061Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G012':
        return G012Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G072':
        return G072Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G073':
        return G073Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G074':
        return G074Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G075':
        return G075Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G076':
        return G076Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G077':
        return G077Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G078':
        return G078Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G079':
        return G079Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G080':
        return G080Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G081':
        return G081Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G082':
        return G082Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G083':
        return G083Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G084':
        return G084Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G085':
        return G085Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G086':
        return G086Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G087':
        return G087Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G088':
        return G088Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G089':
        return G089Controller(challenge: challenge, profile: profile, seed: seed);
      case 'G090':
        return G090Controller(challenge: challenge, profile: profile, seed: seed);
      default:
        // Default fallback to G001 if not yet implemented
        return G001Controller(challenge: challenge, profile: profile, seed: seed);
    }
  }

  static Challenge createDefaultChallenge(String gameId, {int tier = 1}) {
    switch (gameId) {
      case 'G001':
        return Challenge(
          id: 'G001_T${tier}_C01',
          gameId: 'G001',
          tier: tier,
          promptEn: 'Find numbers from 1 to 1000 in sequence!',
          promptHi: 'क्रम में 1 से 1000 तक संख्याएं खोजें!',
          taskData: {'numbersPerStage': 50, 'totalStages': 20},
          validAnswers: [1],
          helpStepsEn: ['Look for the target number in order', 'Follow the numbers in sequence across 20 stages up to 1000'],
          helpStepsHi: ['क्रम में लक्षित संख्या खोजें', '1000 तक 20 चरणों में क्रम से आगे बढ़ें'],
        );
      case 'G002':
        return Challenge(
          id: 'G002_T${tier}_C01',
          gameId: 'G002',
          tier: tier,
          promptEn: 'Count the apples on the tree!',
          promptHi: 'पेड़ पर लगे सेबों को गिनें!',
          taskData: {'fruitCount': tier == 1 ? 4 : (tier == 2 ? 6 : 8)},
          validAnswers: [tier == 1 ? 4 : (tier == 2 ? 6 : 8)],
          helpStepsEn: ['Tap each apple to count aloud', 'Choose the matching number below'],
          helpStepsHi: ['प्रत्येक सेब को छूकर गिनें', 'नीचे सही संख्या चुनें'],
        );
      case 'G011':
        return Challenge(
          id: 'G011_T${tier}_C01',
          gameId: 'G011',
          tier: tier,
          promptEn: 'Find the matching letter!',
          promptHi: 'सही अक्षर पहचानें!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Look at the big target letter', 'Select the card with the same shape'],
          helpStepsHi: ['बड़े अक्षर को ध्यान से देखें', 'वही अक्षर चुनें'],
        );
      case 'G021':
        return Challenge(
          id: 'G021_T${tier}_C01',
          gameId: 'G021',
          tier: tier,
          promptEn: 'Find the hidden picture words in the grid!',
          promptHi: 'ग्रिड में छिपे शब्दों को ढूंढें!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Tap the first and last letter of the word'],
          helpStepsHi: ['शब्द के पहले और आखिरी अक्षर को छुएं'],
        );
      case 'G031':
        return Challenge(
          id: 'G031_T${tier}_C01',
          gameId: 'G031',
          tier: tier,
          promptEn: 'Help the shapes find their matching homes!',
          promptHi: 'आकारों को उनके सही घर में पहुंचाएं!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Drag the shape or tap it, then tap its silhouette'],
          helpStepsHi: ['आकार को उसकी छाया पर रखें'],
        );
      case 'G041':
        return Challenge(
          id: 'G041_T${tier}_C01',
          gameId: 'G041',
          tier: tier,
          promptEn: 'Flip cards to find all the matching pairs!',
          promptHi: 'कार्ड पलटकर जोड़ियां बनाएं!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Remember where each picture is hiding'],
          helpStepsHi: ['याद रखें कौन सा चित्र कहाँ छिपा है'],
        );
      case 'G051':
        return Challenge(
          id: 'G051_T${tier}_C01',
          gameId: 'G051',
          tier: tier,
          promptEn: 'Assemble the animal puzzle!',
          promptHi: 'जानवर की पहेली पूरी करें!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Drag or tap each puzzle piece into the frame'],
          helpStepsHi: ['टुकड़ों को फ्रेम में सही जगह लगाएं'],
        );
      case 'G061':
        return Challenge(
          id: 'G061_T${tier}_C01',
          gameId: 'G061',
          tier: tier,
          promptEn: 'Find the one that does not belong!',
          promptHi: 'जो समूह से अलग है उसे पहचानें!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Look at what category most items share', 'Find the single item that is different'],
          helpStepsHi: ['देखें कि अधिकांश वस्तुएं किस समूह की हैं', 'जो अलग है उसे चुनें'],
        );
      case 'G012':
        return Challenge(
          id: 'G012_T${tier}_C01',
          gameId: 'G012',
          tier: tier,
          promptEn: 'Tap letters A to Z in order!',
          promptHi: 'A से Z तक अक्षरों को क्रम में छुएं!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Find the highlighted letter', 'Tap A first, then B, C...'],
          helpStepsHi: ['हाइलाइट किए गए अक्षर को खोजें', 'पहले A छुएं, फिर B, C...'],
        );
      case 'G072':
        return Challenge(
          id: 'G072_T${tier}_C01',
          gameId: 'G072',
          tier: tier,
          promptEn: 'Connect letters to spell simple words!',
          promptHi: 'अक्षरों को जोड़कर शब्द बनाएं!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Drag your finger over adjacent letters', 'Spell the word shown at the top'],
          helpStepsHi: ['पास के अक्षरों पर उंगली खींचें', 'ऊपर दिखाए गए शब्द बनाएं'],
        );
      case 'G073':
        return Challenge(
          id: 'G073_T${tier}_C01',
          gameId: 'G073',
          tier: tier,
          promptEn: 'Spell the word by tapping letters in order!',
          promptHi: 'क्रम में अक्षरों को छूकर शब्द बनाएं!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Look at the picture', 'Tap the letters in spelling order'],
          helpStepsHi: ['चित्र देखें', 'वर्तनी क्रम में अक्षरों को छुएं'],
        );
      case 'G074':
        return Challenge(
          id: 'G074_T${tier}_C01',
          gameId: 'G074',
          tier: tier,
          promptEn: 'Count objects and solve math puzzles!',
          promptHi: 'वस्तुओं को गिनें और गणित पहेलियां हल करें!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Count the items on screen', 'Tap the correct number answer'],
          helpStepsHi: ['स्क्रीन पर वस्तुएं गिनें', 'सही संख्या वाले बटन को छुएं'],
        );
      case 'G075':
        return Challenge(
          id: 'G075_T${tier}_C01',
          gameId: 'G075',
          tier: tier,
          promptEn: 'Complete the pattern sequence!',
          promptHi: 'पैटर्न क्रम को पूरा करें!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Look at the repeating pattern', 'Choose what comes next in the slot'],
          helpStepsHi: ['दोहराए जाने वाले पैटर्न को देखें', 'क्रम में अगला सही विकल्प चुनें'],
        );
      case 'G076':
        return Challenge(
          id: 'G076_T${tier}_C01',
          gameId: 'G076',
          tier: tier,
          promptEn: 'Identify which animal makes the sound!',
          promptHi: 'पहचानें कि कौन सा जानवर यह आवाज निकालता है!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Read or listen to the sound', 'Tap the matching animal card'],
          helpStepsHi: ['आवाज पढ़ें या सुनें', 'मिलान वाले जानवर के कार्ड को छुएं'],
        );
      case 'G077':
        return Challenge(
          id: 'G077_T${tier}_C01',
          gameId: 'G077',
          tier: tier,
          promptEn: 'Look at the animal and choose the correct name!',
          promptHi: 'जानवर को देखें और उसका सही नाम चुनें!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Look at the animal picture', 'Tap the button with its name'],
          helpStepsHi: ['जानवर का चित्र देखें', 'उसके नाम वाले बटन को छुएं'],
        );
      case 'G078':
        return Challenge(
          id: 'G078_T${tier}_C01',
          gameId: 'G078',
          tier: tier,
          promptEn: 'Find and match the word that rhymes!',
          promptHi: 'तुक मिलाने वाला शब्द खोजें और मिलान करें!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Look at the target word', 'Find a word with the same ending sound'],
          helpStepsHi: ['लक्ष्य शब्द देखें', 'समान ध्वनि वाला शब्द चुनें'],
        );
      case 'G079':
        return Challenge(
          id: 'G079_T${tier}_C01',
          gameId: 'G079',
          tier: tier,
          promptEn: 'Trace the letter with your finger following the numbers!',
          promptHi: 'संख्याओं का पालन करते हुए उंगली से अक्षर बनाएं!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Start at number 1', 'Drag smoothly along the dotted line'],
          helpStepsHi: ['नंबर 1 से शुरू करें', 'बिन्दुओं के ऊपर उंगली चलाएं'],
        );
      case 'G080':
        return Challenge(
          id: 'G080_T${tier}_C01',
          gameId: 'G080',
          tier: tier,
          promptEn: 'Tap the rainbow bars to play musical melodies!',
          promptHi: 'संगीत की धुन बजाने के लिए इंद्रधनुषी पट्टियों को छुएं!',
          taskData: {'songIndex': 0},
          validAnswers: [],
          helpStepsEn: ['Tap the sparkling star note', 'Follow the rainbow sequence to finish the song'],
          helpStepsHi: ['चमकते सितारे वाले स्वर को छुएं', 'गाना पूरा करने के लिए इंद्रधनुषी क्रम का पालन करें'],
        );
      case 'G081':
        return Challenge(
          id: 'G081_T${tier}_C01',
          gameId: 'G081',
          tier: tier,
          promptEn: 'Drag each colorful item into its matching bin!',
          promptHi: 'रंग-बिरंगी वस्तुओं को सही डिब्बे में खींचें!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Tap or drag an item', 'Drop it into the box of the same color'],
          helpStepsHi: ['वस्तु को उठाएं या खींचें', 'समान रंग वाले डिब्बे में डालें'],
        );
      case 'G082':
        return Challenge(
          id: 'G082_T${tier}_C01',
          gameId: 'G082',
          tier: tier,
          promptEn: 'Help each animal find its natural home!',
          promptHi: 'प्रत्येक जानवर को उसके सही घर तक पहुंचाएं!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Look at where the animal lives', 'Drag the animal to its matching habitat'],
          helpStepsHi: ['देखें कि जानवर कहाँ रहता है', 'जानवर को उसके घर में खींचें'],
        );
      case 'G083':
        return Challenge(
          id: 'G083_T${tier}_C01',
          gameId: 'G083',
          tier: tier,
          promptEn: 'Mix two primary colors to create a new color!',
          promptHi: 'दो मूल रंग मिलाकर नया रंग बनाओ!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Pick two colors', 'Tap Mix to see the result'],
          helpStepsHi: ['दो रंग चुनें', 'मिलाओ बटन दबाएं'],
        );
      case 'G084':
        return Challenge(
          id: 'G084_T${tier}_C01',
          gameId: 'G084',
          tier: tier,
          promptEn: 'Brush every tooth zone sparkling clean!',
          promptHi: 'हर दांत को चमकदार साफ करो!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Tap or swipe on the glowing tooth', 'Brush 3 times per zone'],
          helpStepsHi: ['चमकते दांत पर टैप/स्वाइप करो', 'हर ज़ोन को 3 बार ब्रश करो'],
        );
      case 'G085':
        return Challenge(
          id: 'G085_T${tier}_C01',
          gameId: 'G085',
          tier: tier,
          promptEn: 'Gather clues and solve the mystery!',
          promptHi: 'सुराग इकट्ठा करो और रहस्य सुलझाओ!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Read the story', 'Find clues and pick the suspect'],
          helpStepsHi: ['कहानी पढ़ो', 'सुराग ढूंढो और संदिग्ध चुनो'],
        );
      case 'G086':
        return Challenge(
          id: 'G086_T${tier}_C01',
          gameId: 'G086',
          tier: tier,
          promptEn: 'Travel to planets and learn fun facts!',
          promptHi: 'ग्रहों की यात्रा करो और मज़ेदार तथ्य सीखो!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Visit a planet', 'Read the fact and answer the quiz'],
          helpStepsHi: ['ग्रह पर जाओ', 'तथ्य पढ़ो और क्विज़ का जवाब दो'],
        );
      case 'G087':
        return Challenge(
          id: 'G087_T${tier}_C01',
          gameId: 'G087',
          tier: tier,
          promptEn: 'Read the story and pick the right emotion!',
          promptHi: 'कहानी पढ़ो और सही भावना चुनो!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Read the scenario', 'Tap the emotion that matches'],
          helpStepsHi: ['स्थिति पढ़ो', 'सही भावना का इमोजी छुओ'],
        );
      case 'G088':
        return Challenge(
          id: 'G088_T${tier}_C01',
          gameId: 'G088',
          tier: tier,
          promptEn: 'Dig the grid to find hidden dinosaur bones!',
          promptHi: 'ग्रिड खोदो और डायनासोर की हड्डियां ढूंढो!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Tap a dirt cell to dig', 'Numbers show nearby bones'],
          helpStepsHi: ['मिट्टी पर टैप करो', 'संख्या = पास की हड्डियां'],
        );
      case 'G089':
        return Challenge(
          id: 'G089_T${tier}_C01',
          gameId: 'G089',
          tier: tier,
          promptEn: 'Pop the balloon with the right number!',
          promptHi: 'सही संख्या वाला गुब्बारा फोड़ो!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Look at the target number', 'Pop the matching balloon'],
          helpStepsHi: ['लक्ष्य संख्या देखो', 'मिलान वाला गुब्बारा फोड़ो'],
        );
      case 'G090':
        return Challenge(
          id: 'G090_T${tier}_C01',
          gameId: 'G090',
          tier: tier,
          promptEn: 'Arrange items in size order!',
          promptHi: 'चीजों को आकार क्रम में सजाओ!',
          taskData: {},
          validAnswers: [],
          helpStepsEn: ['Read the instruction', 'Pick items in the correct size order'],
          helpStepsHi: ['निर्देश पढ़ो', 'सही आकार क्रम में चुनो'],
        );
      default:
        return Challenge(
          id: '${gameId}_T1_C01',
          gameId: gameId,
          tier: 1,
          promptEn: 'Play and learn!',
          promptHi: 'खेलें और सीखें!',
          taskData: {},
          validAnswers: [],
        );
    }
  }
}
