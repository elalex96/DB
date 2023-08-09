USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'AP_ConsultarInformacionPerfilPorUsuario'
)
    DROP PROCEDURE AP_ConsultarInformacionPerfilPorUsuario;
/****** Object:  StoredProcedure [dbo].[AP_ConsultarInformacionPerfilPorUsuario]    Script Date: 08/08/2023 05:27:56 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Daniel AC
-- Create date: 08/08/2023
-- Description:	Obtener el pais y código del pais por usuario
-- =============================================
CREATE PROCEDURE [dbo].[AP_ConsultarInformacionPerfilPorUsuario] 
	-- Add the parameters for the stored procedure here
@IdUsuario  INT          = 0,
@IdContrato INT          = 0
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;

	 SELECT 
	 Nombre,
	 NumeroCelular,
	 Foto As Foto,  
	 U.CodigoPais AS IdPais,
	 P.CodigoPais AS CodigoPais
	 FROM AP_Usuario U   (NOLOCK)
	 LEFT JOIN dbo.AP_Paises P (NOLOCK)
		ON U.CodigoPais = p.idPais
	 WHERE  U.UsuarioID = @IdUsuario


END;
