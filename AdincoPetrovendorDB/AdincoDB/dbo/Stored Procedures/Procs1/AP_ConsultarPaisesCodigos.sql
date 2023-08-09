USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'AP_ConsultarPaisesCodigos'
)
    DROP PROCEDURE AP_ConsultarPaisesCodigos;
/****** Object:  StoredProcedure [dbo].[sp_AP_ActualizaDatosPerfil]    Script Date: 08/08/2023 05:27:56 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Daniel AC
-- Create date: 08/08/2023
-- Description:	Consultar código de país
-- =============================================
CREATE PROCEDURE [dbo].[AP_ConsultarPaisesCodigos] 
	-- Add the parameters for the stored procedure here
@IdUsuario  INT          = 0,
@IdContrato INT          = 0
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;

CREATE TABLE #Paises (IdPais INT, NombrePais VARCHAR(MAX))
 
 --> AGREGAR QUE MEXICO SE LA PRIMER OPCIÓN
 INSERT INTO #Paises(IdPais, NombrePais)
 SELECT idPais AS IdPais,
 CONCAT(NombrePais,' (+', CodigoPais,+')') AS NombrePais
 FROM AP_Paises (NOLOCK)
 where NombrePais = 'México'
 ORDER BY NombrePais ASC

 
  INSERT INTO #Paises(IdPais, NombrePais)
 SELECT idPais AS IdPais,
 CONCAT(NombrePais,' (+', CodigoPais,+')') AS NombrePais
 FROM AP_Paises (NOLOCK)
 where NombrePais <> 'México'
 ORDER BY NombrePais ASC

 SELECT IdPais, NombrePais 
 FROM #Paises

END;
