//
//  scheme.swift
//  leetcoder
//
//  Created by EricJia on 2019/8/9.
//  Copyright © 2019 EricJia. All rights reserved.
//

import Foundation

class GraphqlSchema: NSObject {
//    query
//    operationName: "questionTopicsList"
//    variables: {orderBy: "most_votes", query: "", skip: 0, first: 15, tags: [], questionId: "1"}
    static let TopicsList = """
query questionTopicsList($questionId: String!, $orderBy: TopicSortingOption, $skip: Int, $query: String, $first: Int!, $tags: [String!]) {
  questionTopicsList(questionId: $questionId, orderBy: $orderBy, skip: $skip, query: $query, first: $first, tags: $tags) {
    ...TopicsList
    __typename
  }
}

fragment TopicsList on TopicConnection {
  totalNum
  edges {
    node {
      id
      title
      commentCount
      viewCount
      pinned
      tags {
        name
        slug
        __typename
      }
      post {
        id
        voteCount
        creationDate
        author {
          username
          isActive
          profile {
            userSlug
            userAvatar
            __typename
          }
          __typename
        }
        status
        coinRewards {
          ...CoinReward
          __typename
        }
        __typename
      }
      lastComment {
        id
        post {
          id
          author {
            isActive
            username
            profile {
              userSlug
              __typename
            }
            __typename
          }
          peek
          creationDate
          __typename
        }
        __typename
      }
      __typename
    }
    cursor
    __typename
  }
  __typename
}

fragment CoinReward on ScoreNode {
  id
  score
  description
  date
  __typename
}
"""

    static let Problem = """
query questionData($titleSlug: String!) {
  question(titleSlug: $titleSlug) {
    questionId
    titleSlug
    title
    translatedTitle
    content
    translatedContent
    isPaidOnly
    difficulty
    likes
    dislikes
    topicTags {
      name
      slug
      translatedName
    }
    codeSnippets {
      lang
      langSlug
      code
    }
    stats
    sampleTestCase
    judgerAvailable
    judgeType
    enableRunCode
    enableTestMode
  }
}
"""
    
//    operationName: "DiscussTopic"
//    query: xxx
//    variables: {topicId: 17}
    static let DiscussTopic = """
query topic {
  topic(id: $topicId) {
    id
    title
    post {
      content
    }
  }
}
"""
    
    static let cnPublicUser = """
query userPublicProfile($userSlug: String!) {
  userProfilePublicProfile(userSlug: $userSlug) {
    username
    haveFollowed
    siteRanking
    profile {
      userSlug
      realName
      aboutMe
      userAvatar
      location
      gender
      websites
      skillTags
      contestCount
      asciiCode
      ranking {
        rating
        ranking
        currentLocalRanking
        currentGlobalRanking
        currentRating
        ratingProgress
        totalLocalUsers
        totalGlobalUsers
        __typename
      }
      skillSet {
        langLevels {
          langName
          langVerboseName
          level
          __typename
        }
        topics {
          slug
          name
          translatedName
          __typename
        }
        topicAreaScores {
          score
          topicArea {
            name
            slug
            __typename
          }
          __typename
        }
        __typename
      }
      socialAccounts {
        provider
        profileUrl
        __typename
      }
      __typename
    }
    educationRecordList {
      unverifiedOrganizationName
      __typename
    }
    occupationRecordList {
      unverifiedOrganizationName
      jobTitle
      __typename
    }
    submissionProgress {
      totalSubmissions
      waSubmissions
      acSubmissions
      reSubmissions
      otherSubmissions
      acTotal
      questionTotal
      __typename
    }
    __typename
  }
}
"""
    
    static let cnUser = """
query globalData {
  feature {
    questionTranslation
    subscription
    signUp
    discuss
    mockInterview
    contest
    store
    book
    chinaProblemDiscuss
    socialProviders
    studentFooter
    cnJobs
    __typename
  }
  userStatus {
    isSignedIn
    isAdmin
    isStaff
    isSuperuser
    isTranslator
    isPremium
    isVerified
    isPhoneVerified
    isWechatVerified
    checkedInToday
    username
    realName
    userSlug
    groups
    jobsCompany {
      nameSlug
      logo
      description
      name
      legalName
      isVerified
      permissions {
        canInviteUsers
        canInviteAllSite
        leftInviteTimes
        maxVisibleExploredUser
        __typename
      }
      __typename
    }
    avatar
    optedIn
    requestRegion
    region
    activeSessionId
    permissions
    notificationStatus {
      lastModified
      numUnread
      __typename
    }
    completedFeatureGuides
    useTranslation
    __typename
  }
  siteRegion
  chinaHost
  websocketUrl
}
"""
    
    static let cnSolutions = """
query questionSolutionArticles($questionSlug: String!, $skip: Int, $first: Int, $orderBy: SolutionArticleOrderBy, $userInput: String) {
  questionSolutionArticles(questionSlug: $questionSlug, skip: $skip, first: $first, orderBy: $orderBy, userInput: $userInput) {
    totalNum
    edges {
      node {
        ...article
        __typename
      }
      __typename
    }
    __typename
  }
}

fragment article on SolutionArticleNode {
  title
  slug
  status
  identifier
  createdAt
  thumbnail
  author {
    username
    profile {
      userAvatar
      userSlug
      realName
    }
  }
  summary
  upvoteCount
}
"""
    
    static let cnSolutionDetail = """
query solutionDetailArticle($slug: String!) {
  solutionArticle(slug: $slug) {
    ...article
    content
    __typename
  }
}

fragment article on SolutionArticleNode {
  title
  slug
  reactedType
  status
  identifier
  canEdit
  reactions {
    count
    reactionType
    __typename
  }
  tags {
    name
    nameTranslated
    slug
    __typename
  }
  createdAt
  thumbnail
  author {
    username
    profile {
      userAvatar
      userSlug
      realName
      __typename
    }
    __typename
  }
  summary
  topic {
    id
    commentCount
    viewCount
    __typename
  }
  byLeetcode
  isMyFavorite
  isMostPopular
  isEditorsPick
  upvoteCount
  upvoted
  hitCount
  __typename
}
"""
    
    static let cnComments = """
query commentsSelection($topicId: ID!) {
  commentsSelection(topicId: $topicId) {
    ...commentFields
    __typename
  }
}

fragment commentFields on CommentRelayNode {
  id
  numChildren
  isEdited
  post {
    id
    content
    voteUpCount
    creationDate
    updationDate
    status
    voteStatus
    author {
      username
      isDiscussAdmin
      profile {
        userSlug
        userAvatar
        realName
        __typename
      }
      __typename
    }
    mentionedUsers {
      key
      username
      userSlug
      nickName
      __typename
    }
    __typename
  }
  __typename
}
"""
    
    static let cnProblem = """
query questionData($titleSlug: String!) {
  question(titleSlug: $titleSlug) {
    questionId
    questionFrontendId
    boundTopicId
    title
    titleSlug
    content
    translatedTitle
    translatedContent
    isPaidOnly
    difficulty
    likes
    dislikes
    isLiked
    similarQuestions
    contributors {
      username
      profileUrl
      avatarUrl
      __typename
    }
    langToValidPlayground
    topicTags {
      name
      slug
      translatedName
      __typename
    }
    companyTagStats
    codeSnippets {
      lang
      langSlug
      code
      __typename
    }
    stats
    hints
    solution {
      id
      canSeeDetail
      __typename
    }
    status
    sampleTestCase
    metaData
    judgerAvailable
    judgeType
    mysqlSchemas
    enableRunCode
    enableTestMode
    envInfo
    book {
      id
      bookName
      pressName
      description
      bookImgUrl
      pressImgUrl
      productUrl
      __typename
    }
    isSubscribed
    __typename
  }
}
"""
}
