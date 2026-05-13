USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MPY_UsuarioPreFactura'
)
    DROP PROCEDURE SP_MPY_UsuarioPreFactura;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 06/11/2018
-- Description:	Consultas de usuario de la carga 
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 10/05/2023
-- Description:	se agrega el filtrado por usuario activo, nolocks y reacomodo de joins
-- =============================================
CREATE procedure [dbo].[SP_MPY_UsuarioPreFactura]
	-- Add the parameters for the stored procedure here
	@IdPRESES INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		US.IdUsuario,
		US.Nombre,
		US.Correo
	FROM Adinco.dbo.CO_SAPPRESES AS PSES (NOLOCK)
	LEFT JOIN dbo.S_Usuario AS US (NOLOCK) ON PSES.CreadoPor = US.IdUsuario 
		AND US.Activo = 1
	WHERE PSES.IdPRESES = @IdPRESES;

END
