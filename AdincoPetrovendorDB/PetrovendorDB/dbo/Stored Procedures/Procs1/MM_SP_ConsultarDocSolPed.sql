USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[MM_SP_ConsultarDocSolPed]    Script Date: 26/11/2021 01:45:37 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <02-03-2018>
-- Description:	<Consulta de documentos por SolPed>
-- =============================================
-- =============================================
-- Author:		<Pedro Acu�a>
-- Create date: <11-09-2018>
-- Description:	<se agrega el bit de activo o inactivo>
-- =============================================

ALTER PROCEDURE [dbo].[MM_SP_ConsultarDocSolPed] @IdSolPed INT ,
											/*--------------------parametros contrato  --------------------*/
										  @IdContrato INT = NULL, @IdUsuario INT = NULL, @FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
	BEGIN
		SELECT	IdDocumento, NombreDoc
		FROM	dbo.MM_DocumentosSolPed (NOLOCK)
		WHERE
				IdSolPed = @IdSolPed
				AND Activo = 1
	END
