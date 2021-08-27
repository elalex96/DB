USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_DEAUsuarios]    Script Date: 26/08/2021 12:42:33 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 25/08/2021
-- Description:	Devuelve usuarios descripción SAP
-- =============================================
CREATE PROCEDURE SP_DEAUsuariosDescripcionSAP
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IdContratista INT
	--
	SET @IdContratista = 
	(SELECT DISTINCT IdContratista
	FROM [S_UsuarioProveedor] UP
	JOIN Adinco.dbo.CO_Contrato C ON UP.idContrato = C.IdContrato
	WHERE UP.IdProveedor = @IdProveedor)
    -- Insert statements for procedure here
	SELECT 
	D.IdUsuarioSolicitanteSAP,
	S.Nombre AS Usuario,
	D.DescripcionSAP,
	SC.Nombre AS UsuarioQueRegistra,
	D.CreadoEn,
	D.ModificadoEn
	FROM [dbo].[DEA_UsuarioSolicitanteSAP] D
	JOIN S_Usuario S ON D.IdUsuario = S.IdUsuario
	JOIN S_Usuario SC ON D.CreadoPor = SC.IdUsuario
	LEFT JOIN S_Usuario SM ON D.ModificadoPor = SM.IdUsuario
	WHERE D.IsEliminado = 0 AND D.IdContratista = @IdContratista
	
END
GO