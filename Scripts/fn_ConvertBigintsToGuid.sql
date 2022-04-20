/****** Object:  UserDefinedFunction [dbo].[fn_ConvertBigintsToGuid]    Script Date: 30.07.2020 11:49:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_ConvertBigintsToGuid](@input1 bigint, @input2 bigint)
RETURNS uniqueidentifier
AS
BEGIN
	DECLARE @hexString varchar(34) = '0x' + dbo.fn_ConvertBigintToHexString(@input1) + dbo.fn_ConvertBigintToHexString(@input2)
	RETURN CAST(CONVERT(varbinary(128), @hexString, 1) AS uniqueidentifier)
END
GO


