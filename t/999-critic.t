use Test::Perl::Critic (-severity => 'brutal', -exclude => ['RequireRcsKeywords', 'RequireTidyCode', 'requirePodSections']);
all_critic_ok();
