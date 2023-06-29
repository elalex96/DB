USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_ValidarCartasPorAceptacionExistente'
)
    DROP PROCEDURE SP_MM_ValidarCartasPorAceptacionExistente;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 12/06/2023
-- Description:	Validacion de cartas de contenido nacional existentes relacionadas a una aceptacion
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ValidarCartasPorAceptacionExistente]
	-- Add the parameters for the stored procedure here
	@IdAceptacionPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF EXISTS (SELECT IdAceptacionCartaPCN FROM MM_AceptacionCartaPCN WHERE IdAceptacionPedido = @IdAceptacionPedido AND Activo = 1 AND IdEstatus IN (1,2))
	BEGIN
		
		SELECT 1 EXISTE

	END
	ELSE
	BEGIN
		
		SELECT 0 AS EXISTE
		
	END

END

GO
