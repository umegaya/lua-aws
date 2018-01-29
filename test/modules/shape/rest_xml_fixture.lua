return {
	s3_listobjects_resp = {
		header = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n", 
		value = {
			ListBucketResult = {
				xarg = {xmlns = "http://s3.amazonaws.com/doc/2006-03-01/"}, 
				list = true, 
				value = {
					IsTruncated = {xarg = {}, value = "false"}, 
					Prefix = {xarg = {}}, 
					Contents = {
						{
							xarg = {}, 
							value = {
								LastModified = {xarg = {}, value = "2017-12-25T01:23:37.000Z"}, 
								Size = {xarg = {}, value = "26179"}, 
								StorageClass = {xarg = {}, value = "STANDARD"}, 
								Owner = {
									xarg = {}, 
									value = {
										DisplayName = {xarg = {}, value = "iyatomi_takehiro"}, 
										ID = {xarg = {}, value = "2ce54f564fefe4a9a9f7227b7b4294638d6a65833510c025c7d3f74bef569785"}
									}
								}, 
								Key = {xarg = {}, value = "BmB9X3YIEAARNWy.jpg"}, 
								ETag = {xarg = {}, value = "\"33a49d53a0e13e096b397b692a64b68c\""}
							}
						}, 
						{
							xarg = {}, 
							value = {
								LastModified = {xarg = {}, value = "2017-12-25T01:23:38.000Z"}, 
								Size = {xarg = {}, value = "26179"}, 
								StorageClass = {xarg = {}, value = "STANDARD"}, 
								Owner = {
									xarg = {}, 
									value = {
										DisplayName = {xarg = {}, value = "iyatomi_takehiro"}, 
										ID = {xarg = {}, value = "2ce54f564fefe4a9a9f7227b7b4294638d6a65833510c025c7d3f74bef569785"}
									}
								}, 
								Key = {xarg = {}, value = "file2.jpg"}, 
								ETag = {xarg = {}, value = "\"33a49d53a0e13e096b397b692a64b68c\""}
							}
						}
					}, 
					Name = {xarg = {}, value = "lua-aws-test-1514164967"}, 
					MaxKeys = {xarg = {}, value = "1000"}, 
					Marker = {xarg = {}}
				}
			}
		}
	}, 
	s3_listobjects_single_resp = {
		header = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n", 
		value = {
			ListBucketResult = {
				xarg = {xmlns = "http://s3.amazonaws.com/doc/2006-03-01/"}, 
				value = {
					IsTruncated = {xarg = {}, value = "false"}, 
					Prefix = {xarg = {}}, 
					Contents = {
						xarg = {}, 
						value = {
							LastModified = {xarg = {}, value = "2017-12-25T03:15:21.000Z"}, 
							Size = {xarg = {}, value = "26179"}, 
							StorageClass = {xarg = {}, value = "STANDARD"}, 
							Owner = {
								xarg = {}, 
								value = {
									DisplayName = {xarg = {}, value = "iyatomi_takehiro"}, 
									ID = {xarg = {}, value = "2ce54f564fefe4a9a9f7227b7b4294638d6a65833510c025c7d3f74bef569785"}
								}
							}, 
							Key = {xarg = {}, value = "BmB9X3YIEAARNWy.jpg"}, 
							ETag = {xarg = {}, value = "\"33a49d53a0e13e096b397b692a64b68c\""}
						}
					}, 
					Name = {xarg = {}, value = "lua-aws-test-1514171671"}, 
					MaxKeys = {xarg = {}, value = "1000"}, 
					Marker = {xarg = {}}
				}
			}
		}
	},
	s3_listbuckets_resp = {
		header = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n", 
		value = {
			ListAllMyBucketsResult = {
				xarg = {xmlns = "http://s3.amazonaws.com/doc/2006-03-01/"}, 
				value = {
					Buckets = {
						xarg = {}, 
						list = true, 
						value = {
							Bucket = {
								{
									xarg = {}, 
									value = {
										Name = {xarg = {}, value = "dokyogames-redshift-bucket"}, 
										CreationDate = {xarg = {}, value = "2015-11-05T03:30:58.000Z"}
									}
								}, {
									xarg = {}, 
									value = {
										Name = {xarg = {}, value = "elasticbeanstalk-us-east-1-871570535967"}, 
										CreationDate = {xarg = {}, value = "2014-07-17T02:23:53.000Z"}
									}
								}, {
									xarg = {}, 
									value = {
										Name = {xarg = {}, value = "lua-aws-test-1513675884"}, 
										CreationDate = {xarg = {}, value = "2017-12-25T00:46:13.000Z"}
									}
								}, {
									xarg = {}, 
									value = {
										Name = {xarg = {}, value = "lua-aws-test-1514168660"}, 
										CreationDate = {xarg = {}, value = "2017-12-25T02:25:07.000Z"}
									}
								}
							}
						}
					}, 
					Owner = {
						xarg = {}, 
						value = {
							DisplayName = {xarg = {}, value = "iyatomi_takehiro"}, 
							ID = {xarg = {}, value = "2ce54f564fefe4a9a9f7227b7b4294638d6a65833510c025c7d3f74bef569785"}
						}
					}
				}
			}
		}
	}
}
