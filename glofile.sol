/**
 * @title Glofile
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract Glofile {

  enum GlofileType { Anon, Person, Project, Organization, Proxy, Parody, Bot }
  enum SafetyLevel { Safe, NSFW, NSFL }

  struct Glofile {
    bool dontIndex;
    GlofileType glofileType;
    SafetyLevel safetyLevel;
    uint16 publicKeyCount;
    bytes uris;
    string fullName;
    string location;
    bytes3[] foregroundColors;
    bytes3[] backgroundColors;
    bytes3[] bioLangs;
    bytes[] avatars;
    bytes[] coverImages;
    bytes[] backgroundImages;
    string[] topics;
    string[] parents;
    string[] children;
    mapping (bytes3 => bytes) bioTranslations;
  }

  mapping (address => Glofile) glofiles;

  event Update(address indexed account);
  event Delete(address indexed account);
  event PublicKeyAdd(address indexed account, uint indexed i, bytes publicKey);
  event PublicKeyDelete(address indexed account, uint indexed i);

  /**
   * @notice Set your Glofile don't index flag to `dontIndex`
   * @dev Sets the "don't index" flag. Glofiles with this flag set should only be accessible directly and not be discoverable via search.
   * @param dontIndex flag to indicate that this Glofile should not be indexed
   */
  function setDontIndex(bool dontIndex) {
    glofiles[msg.sender].dontIndex = dontIndex;
    Update(msg.sender);
  }

  /**
   * @notice Set your Glofile type to `glofileType`
   * @dev Sets the Glofile type.
   * @param glofileType Glofile type
   */
  function setGlofileType(GlofileType glofileType) {
    glofiles[msg.sender].glofileType = glofileType;
    Update(msg.sender);
  }

  /**
   * @notice Set your Glofile safety level to `safetyLevel`
   * @dev Sets the safety level. The account may publish content that is less safe than this, so long as it is flagged as such.
   * @param safetyLevel safety level
   */
  function setSafetyLevel(SafetyLevel safetyLevel) {
    glofiles[msg.sender].safetyLevel = safetyLevel;
    Update(msg.sender);
  }

  /**
   * @notice Get Glofile basic info
   * @dev Gets all the info that can be retreived in a single call.
   * @param account Glofile to access
   * @return dontIndex flag to indicate that this Glofile should not be indexed
   * @return glofileType Glofile type
   * @return safetyLevel safety level
   */
  function getBasicInfo(address account) constant returns (bool dontIndex, GlofileType glofileType, SafetyLevel safetyLevel) {
    Glofile glofile = glofiles[account];
    dontIndex = glofile.dontIndex;
    glofileType = glofile.glofileType;
    safetyLevel = glofile.safetyLevel;
  }

  /**
   * @notice Set your Glofile full name to `fullName`
   * @dev Sets the full name.
   * @param fullName UTF-8 string of full name - max length 128 chars
   * @return fullName UTF-8 string of full name
   */
  function setFullName(string fullName) {
    glofiles[msg.sender].fullName = fullName;
    Update(msg.sender);
  }

  /**
   * @notice Get Glofile full name for `account`
   * @dev Gets the full name.
   * @param account Glofile to access
   * @return UTF-8 string of full name
   */
  function getFullName(address account) constant returns (string) {
    return glofiles[account].fullName;
  }

  /**
   * @notice Set your Glofile location
   * @dev Sets the location. A dedicated contract could be used for more sophisticated location functionality.
   * @param location UTF-8 string of location - max string length 128 chars
   */
  function setLocation(string location) {
    glofiles[msg.sender].location = location;
    Update(msg.sender);
  }

  /**
   * @notice Get Glofile location for `account`
   * @dev Gets the location.
   * @param account Glofile to access
   * @return UTF-8 string of location
   */
  function getLocation(address account) constant returns (string) {
    return glofiles[account].location;
  }

  /**
   * @notice Set your Glofile foreground colors
   * @dev Sets all the foreground colors.
   * @param colors array of RGB triplets
   */
  function setForegroundColors(bytes3[] colors) {
    glofiles[msg.sender].foregroundColors = colors;
    Update(msg.sender);
  }

  /**
   * @notice Set your Glofile background colors
   * @dev Sets all the background colors.
   * @param colors array of RGB triplets
   */
  function setBackgroundColors(bytes3[] colors) {
    glofiles[msg.sender].backgroundColors = colors;
    Update(msg.sender);
  }

  /**
   * @notice Get Glofile colors
   * @dev Gets the foreground and background colors
   * @param account Glofile to access
   * @return foregroundColors array of RGB triplets of foreground colors
   * @return backgroundColors array of RGB triplets of background colors
   */
  function getColors(address account) constant returns (bytes3[] foregroundColors, bytes3[] backgroundColors) {
    Glofile glofile = glofiles[account];
    foregroundColors = glofile.foregroundColors;
    backgroundColors = glofile.backgroundColors;
  }

  /**
   * @notice Set your Glofile bio with langauge code `lang`
   * @dev Sets the bio in a specific language.
   * @param lang 3 letter ISO 639-3 language code
   * @param translation UTF-8 Markdown of bio compressed with DEFLATE - max Markdown length 256 chars
   */
  function setBio(bytes3 lang, bytes translation) {
    Glofile glofile = glofiles[msg.sender];
    // Check if we already have the language code.
    for (uint i = 0; i < glofile.bioLangs.length; i++) {
      if (glofile.bioLangs[i] == lang) {
        break;
      }
    }
    if (i == glofile.bioLangs.length) {
      // We didn't find it. Try to find a free slot.
      for (i = 0; i < glofile.bioLangs.length; i++) {
        if (glofile.bioLangs[i] == 0) {
          break;
        }
      }
      if (i == glofile.bioLangs.length) {
        // We didn't find a free slot. Make the array bigger.
        glofile.bioLangs.length++;
      }
      glofile.bioLangs[i] = lang;
    }
    // Set translation.
    glofile.bioTranslations[lang] = translation;
    Update(msg.sender);
  }

  /**
   * @notice Delete your Glofile bio with language code `lang`
   * @dev Deletes a bio translation.
   * @param lang 3 letter ISO 639-3 language code
   */
  function deleteBio(bytes3 lang) {
    Glofile glofile = glofiles[msg.sender];
    for (uint i = 0; i < glofile.bioLangs.length; i++) {
      if (glofile.bioLangs[i] == lang) {
        delete glofile.bioLangs[i];
        break;
      }
    }
    // Delete the actual mapping in case a client accesses without checking
    // language key.
    delete glofile.bioTranslations[lang];
    Update(msg.sender);
  }

  /**
   * @notice Delete all of your Glofile bio translations
   * @dev Deletes all of the bio translations.
   */
  function deleteAllBioTranslations() {
    Glofile glofile = glofiles[msg.sender];
    // Delete the actual mappings in case a client accesses without checking
    // language key.
    for (uint i = 0; i < glofile.bioLangs.length; i++) {
      delete glofile.bioTranslations[glofile.bioLangs[i]];
    }
    delete glofile.bioLangs;
    Update(msg.sender);
  }

  /**
   * @notice Get the list of language code a Glofile bio is available in
   * @dev Gets the list of language codes the bio is available in.
   * @param account Glofile to access
   * @return array of 3 letter ISO 639-3 language codes
   */
  function getBioLangCodes(address account) constant returns (bytes3[]) {
    return glofiles[account].bioLangs;
  }

  /**
   * @notice Get the Glofile bio with language code `lang`
   * @dev Gets the bio in a specific language.
   * @param account Glofile to access
   * @param lang 3 letter ISO 639-3 language code
   * @return UTF-8 Markdown of bio compressed with DEFLATE
   */
  function getBioTranslation(address account, bytes3 lang) constant returns (bytes) {
    return glofiles[account].bioTranslations[lang];
  }

  /**
   * @notice Set your Glofile avatar with index `i` to `ipfsHash`
   * @dev Sets the avatar with a specific index to an IPFS hash.
   * @param i index of avatar to set
   * @param ipfsHash binary IPFS hash of image
   */
  function setAvatar(uint i, bytes ipfsHash) {
    bytes[] avatars = glofiles[msg.sender].avatars;
    // Make sure the array is long enough.
    if (avatars.length <= i) {
      avatars.length = i + 1;
    }
    avatars[i] = ipfsHash;
    Update(msg.sender);
  }

  /**
   * @notice Delete your Glofile avatar with index `i`
   * @dev Deletes an avatar with a specific index.
   * @param i index of avatar to delete
   */
  function deleteAvatar(uint i) {
    delete glofiles[msg.sender].avatars[i];
    Update(msg.sender);
  }

  /**
   * @notice Delete all your Glofile avatars
   * @dev Deletes all avatars from the Glofile.
   */
  function deleteAllAvatars() {
    delete glofiles[msg.sender].avatars;
    Update(msg.sender);
  }

  /**
   * @notice Get the number of Glofile avatars
   * @dev Gets the number of avatars.
   * @param account Glofile to access
   * @return number of avatars
   */
  function getAvatarCount(address account) constant returns (uint) {
    return glofiles[account].avatars.length;
  }

  /**
   * @notice Get the Glofile avatar with index `i`
   * @dev Gets the avatar with a specific index.
   * @param account Glofile to access
   * @param i index of avatar to get
   * @return binary IPFS hash of image
   */
  function getAvatar(address account, uint i) constant returns (bytes) {
    return glofiles[account].avatars[i];
  }

  /**
   * @notice Set your Glofile cover image with index `i` to `ipfsHash`
   * @dev Sets the cover image with a specific index to an IPFS hash.
   * @param i index of cover image to set
   * @param ipfsHash binary IPFS hash of image
   */
  function setCoverImage(uint i, bytes ipfsHash) {
    bytes[] coverImages = glofiles[msg.sender].coverImages;
    // Make sure the array is long enough.
    if (coverImages.length <= i) {
      coverImages.length = i + 1;
    }
    coverImages[i] = ipfsHash;
    Update(msg.sender);
  }

  /**
   * @notice Delete your Glofile cover image with index `i`
   * @dev Deletes the cover image with a specific index.
   * @param i index of cover image to delete
   */
  function deleteCoverImage(uint i) {
    delete glofiles[msg.sender].coverImages[i];
    Update(msg.sender);
  }

  /**
   * @notice Delete all your Glofile cover images
   * @dev Deletes all cover images from the Glofile.
   */
  function deleteAllCoverImages() {
    delete glofiles[msg.sender].coverImages;
    Update(msg.sender);
  }

  /**
   * @notice Get the number of Glofile cover images
   * @dev Gets the number of cover images.
   * @param account Glofile to access
   * @return number of cover images
   */
  function getCoverImageCount(address account) constant returns (uint) {
    return glofiles[account].coverImages.length;
  }

  /**
   * @notice Get the Glofile cover image with index `i`
   * @dev Gets the cover image with a specific index.
   * @param account Glofile to access
   * @param i index of cover image to get
   * @return binary IPFS hash of image
   */
  function getCoverImage(address account, uint i) constant returns (bytes) {
    return glofiles[account].coverImages[i];
  }

  /**
   * @notice Set your Glofile background image with index `i` to `ipfsHash`
   * @dev Sets the background image with a specific index to an IPFS hash.
   * @param i index of background image to set
   * @param ipfsHash binary IPFS hash of image
   */
  function setBackgroundImage(uint i, bytes ipfsHash) {
    bytes[] backgroundImages = glofiles[msg.sender].backgroundImages;
    // Make sure the array is long enough.
    if (backgroundImages.length <= i) {
      backgroundImages.length = i + 1;
    }
    backgroundImages[i] = ipfsHash;
    Update(msg.sender);
  }

  /**
   * @notice Delete your Glofile background image with index `i`
   * @dev Deletes the background image with a specific index.
   * @param i index of background image to delete
   */
  function deleteBackgroundImage(uint i) {
    delete glofiles[msg.sender].backgroundImages[i];
    Update(msg.sender);
  }

  /**
   * @notice Delete all your Glofile background images
   * @dev Deletes all the background images.
   */
  function deleteAllBackgroundImages() {
    delete glofiles[msg.sender].backgroundImages;
    Update(msg.sender);
  }

  /**
   * @notice Get the number of Glofile background images
   * @dev Gets the number of background images.
   * @param account Glofile to access
   * @return number of background images
   */
  function getBackgroundImageCount(address account) constant returns (uint) {
    return glofiles[account].backgroundImages.length;
  }

  /**
   * @notice Get the Glofile background image with index `i`
   * @dev Gets the background image with a specific index.
   * @param i index of cover image to get
   * @param account Glofile to access
   * @return binary IPFS hash of image
   */
  function getBackgroundImage(address account, uint i) constant returns (bytes) {
    return glofiles[account].backgroundImages[i];
  }

  /**
   * @notice Set your Glofile topic with index `i` to `topic`
   * @dev Sets the topic with a specific index.
   * @param i index of topic to set
   * @param topic UTF-8 string of topic (no whitespace)
   */
  function setTopic(uint i, string topic) {
    string[] topics = glofiles[msg.sender].topics;
    // Make sure the array is long enough.
    if (topics.length <= i) {
      topics.length = i + 1;
    }
    topics[i] = topic;
    Update(msg.sender);
  }

  /**
   * @notice Delete your Glofile topic with index `i`
   * @dev Deletes an topic with a specific index.
   * @param i index of topic to delete
   */
  function deleteTopic(uint i) {
    delete glofiles[msg.sender].topics[i];
    Update(msg.sender);
  }

  /**
   * @notice Delete all your Glofile topics
   * @dev Deletes all topics from the Glofile.
   */
  function deleteAllTopics() {
    delete glofiles[msg.sender].topics;
    Update(msg.sender);
  }

  /**
   * @notice Get the number of Glofile topics
   * @dev Gets the number of topics.
   * @param account Glofile to access
   * @return number of topics
   */
  function getTopicCount(address account) constant returns (uint) {
    return glofiles[account].topics.length;
  }

  /**
   * @notice Get the Glofile topic with index `i`
   * @dev Gets the topic with a specific index.
   * @param account Glofile to access
   * @param i index of topic to get
   * @return UTF-8 string of topic
   */
  function getTopic(address account, uint i) constant returns (string) {
    return glofiles[account].topics[i];
  }

  /**
   * @notice Set your Glofile parent with index `i` to `parent`
   * @dev Sets the parent with a specific index.
   * @param i index of parent to set
   * @param parent UTF-8 string of parent
   */
  function setParent(uint i, string parent) {
    string[] parents = glofiles[msg.sender].parents;
    // Make sure the array is long enough.
    if (parents.length <= i) {
      parents.length = i + 1;
    }
    parents[i] = parent;
    Update(msg.sender);
  }

  /**
   * @notice Delete your Glofile parent with index `i`
   * @dev Deletes an parent with a specific index.
   * @param i index of parent to delete
   */
  function deleteParent(uint i) {
    delete glofiles[msg.sender].parents[i];
    Update(msg.sender);
  }

  /**
   * @notice Delete all your Glofile parents
   * @dev Deletes all parents from the Glofile.
   */
  function deleteAllParents() {
    delete glofiles[msg.sender].parents;
    Update(msg.sender);
  }

  /**
   * @notice Get the number of Glofile parents
   * @dev Gets the number of parents.
   * @param account Glofile to access
   * @return number of parents
   */
  function getParentCount(address account) constant returns (uint) {
    return glofiles[account].parents.length;
  }

  /**
   * @notice Get the Glofile parent with index `i`
   * @dev Gets the parent with a specific index.
   * @param account Glofile to access
   * @param i index of parent to get
   * @return UTF-8 string of parent
   */
  function getParent(address account, uint i) constant returns (string) {
    return glofiles[account].parents[i];
  }

  /**
   * @notice Set your Glofile child with index `i` to `child`
   * @dev Sets the child with a specific index.
   * @param i index of child to set
   * @param child UTF-8 string of child
   */
  function setChild(uint i, string child) {
    string[] children = glofiles[msg.sender].children;
    // Make sure the array is long enough.
    if (children.length <= i) {
      children.length = i + 1;
    }
    children[i] = child;
    Update(msg.sender);
  }

  /**
   * @notice Delete your Glofile child with index `i`
   * @dev Deletes an child with a specific index.
   * @param i index of child to delete
   */
  function deleteChild(uint i) {
    delete glofiles[msg.sender].children[i];
    Update(msg.sender);
  }

  /**
   * @notice Delete all your Glofile children
   * @dev Deletes all children from the Glofile.
   */
  function deleteAllChildren() {
    delete glofiles[msg.sender].children;
    Update(msg.sender);
  }

  /**
   * @notice Get the number of Glofile children
   * @dev Gets the number of children.
   * @param account Glofile to access
   * @return number of children
   */
  function getChildCount(address account) constant returns (uint) {
    return glofiles[account].children.length;
  }

  /**
   * @notice Get the Glofile child with index `i`
   * @dev Gets the child with a specific index.
   * @param account Glofile to access
   * @param i index of child to get
   * @return UTF-8 string of child
   */
  function getChild(address account, uint i) constant returns (string) {
    return glofiles[account].children[i];
  }

  /**
   * @notice Add a public key to your Glofile
   * @dev Adds a public key.
   * @param publicKey UTF-8 public key compressed with DEFLATE
   */
  function addPublicKey(bytes publicKey) {
    uint i = glofiles[msg.sender].publicKeyCount++;
    PublicKeyAdd(msg.sender, i, publicKey);
  }

  /**
   * @notice Delete the public key with index `i` from your Glofile
   * @dev Deletes the public key with a specific index.
   * @param i index of public key to delete
   */
  function deletePublicKey(uint i) {
    PublicKeyDelete(msg.sender, i);
  }

  /**
   * @notice Copy entire Glofile from `source`
   * @dev Copies the Glofile from another account to this one.
   * @param source account of Glofile to copy from
   * TODO: check this works
   */
  function copyEntireGlofile(address source) {
    glofiles[msg.sender] = glofiles[source];
    Update(msg.sender);
  }

  /**
   * @notice Delete your entire Glofile
   * @dev Deletes the Glofile completely.
   * TODO: make sure this deletes everything
   */
  function deleteEntireGlofile() {
    delete glofiles[msg.sender];
    Delete(msg.sender);
  }

}
