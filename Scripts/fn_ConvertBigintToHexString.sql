/****** Object:  UserDefinedFunction [dbo].[fn_ConvertBigintToHexString]    Script Date: 30.07.2020 11:49:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_ConvertBigintToHexString](@input bigint)
RETURNS varchar(16)
AS
BEGIN
	RETURN CONVERT(varchar(16), CAST(@input AS varbinary(64)), 2)
END
GO


