USE [Petrovendor]
GO

IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'DEA_SP_UsuarioOBS_Grid'
)
    DROP PROCEDURE DEA_SP_UsuarioOBS_Grid;

/****** Object:  StoredProcedure [dbo].[sp_CentroCostoFiltro_Grd]    Script Date: 13/07/2021 01:17:22 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[DEA_SP_UsuarioOBS_Grid]
AS
BEGIN

	SELECT U.IdUsuario, U.Nombre AS Usuario,C.IdContrato, CONCAT(C.NumeroContrato,ISNULL(' - '+AC.NombreAreaContractual,'')) AS Contrato, U.Correo
	FROM DEA_UsuarioOBS UOBS
	JOIN S_Usuario U
	ON UOBS.IdUsuario=U.IdUsuario
	JOIN Adinco..CO_Contrato C
	ON UOBS.IdContrato = C.IdContrato
	AND UOBS.Activo = 1
	LEFT JOIN Adinco..CO_AreaContractual AC
	ON C.IdAreaContractual =AC.IdAreaContractual
	ORDER BY U.Nombre ASC 
END

