_ = require('lodash')._

extractCharacter = (character) ->
  powerLevel = character.powerLevel
  gender = character.gender.genderType == 1 && character.race.raceNameFemale || character.race.raceNameMale
  className = character.characterClass.className

  "#{gender} #{className} (#{powerLevel})"

extractCharacters = (characters) ->
  _.transform(characters, ((result, character) -> result[character.characterId] = extractCharacter(character)), {})

module.exports = {
  member: (name, bungieAccount) ->
    return {
      name: name,
      membershipId: bungieAccount.bungieNetUser.membershipId,
      clan: bungieAccount.relatedGroups[bungieAccount.clans[0].groupId].name,
      characters: extractCharacters(bungieAccount.destinyAccounts[0].characters)
    }
}