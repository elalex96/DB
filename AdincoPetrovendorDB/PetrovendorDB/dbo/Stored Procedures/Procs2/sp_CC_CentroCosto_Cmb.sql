USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_CC_CentroCosto_Cmb'
)
    DROP PROCEDURE sp_CC_CentroCosto_Cmb;
/****** Object:  StoredProcedure [dbo].[sp_CC_CentroCosto_Cmb]    Script Date: 13/07/2021 01:27:00 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[sp_CC_CentroCosto_Cmb]
(
	@IdProveedor	int
)
as
begin
		select	IdCentroCosto,
				CentroCosto
		from	CC_CentroCosto
		where	((IdProveedor =	@IdProveedor) or @IdProveedor = -1)
		ORDER BY CentroCosto ASC
end

