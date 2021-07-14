USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_S_Proveedor_Cmb'
)
    DROP PROCEDURE sp_S_Proveedor_Cmb;
/****** Object:  StoredProcedure [dbo].[sp_S_Proveedor_Cmb]    Script Date: 13/07/2021 01:24:31 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[sp_S_Proveedor_Cmb]
as
begin
		select	IdProveedor,
				RazonSocial
		from	S_Proveedor
		ORDER BY RazonSocial ASC
		--where IdProveedor = 472
end

