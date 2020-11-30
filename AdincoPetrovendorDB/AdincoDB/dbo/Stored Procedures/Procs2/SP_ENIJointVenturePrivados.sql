-- =============================================
-- Author:		Marcos Garcia
-- Create date: 27-07-2020
-- Description:	Seleciona solo Documentos que han sido marcados 
--              como privados por caso para ocultar el div de privados 
-- =============================================
CREATE PROCEDURE [dbo].[SP_ENIJointVenturePrivados] 
-- [dbo].[SP_ENIJointVenturePrivados] 3,10113,1
@IdContrato INT, 
@IdUsuario  INT, 
@Case       INT
AS
     BEGIN
         SET NOCOUNT ON;
         IF OBJECT_ID('tempdb..#TemporalCorreos', 'U') IS NOT NULL
             DROP TABLE #TemporalCorreos;
         --
         CREATE TABLE #TemporalCorreos
         (Nombre  VARCHAR(MAX), 
          Usuario VARCHAR(MAX)
         );
         --
         INSERT INTO #TemporalCorreos
         (Nombre, 
          Usuario
         )
         VALUES
         ('Felice D´Alterio', 
          'Felice.DAlterio@eni.com'
         ),
         ('Nayeli islas', 
          'nayeli.islas@external.eni.com'
         )--,
         --('Manuel Cruz', 
         -- 'manuel.cruz@adinco.mx'
         --);
         --
         IF @Case = 1
             BEGIN
                 SELECT A.IdAWSDocumento, 
                        C.NumeroContrato AS Contrato, 
                        A.NombreArchivo, 
                        U.Nombre AS CreadoPor, 
                        A.CreadoEl
                 FROM dbo.AWS_DocumentoENI A
                      JOIN dbo.CO_Contrato C ON C.IdContrato = A.IdContrato
                      JOIN dbo.AP_Usuario U ON A.CreadoPor = U.UsuarioID
                      JOIN dbo.AP_Usuario UT ON UT.UsuarioID = @IdUsuario
                      JOIN #TemporalCorreos TC ON UT.Usuario = TC.Usuario
                 WHERE A.Folder = 'ENIArchivos/JOINTVENTURE/'
                       AND ISNULL(A.Privado, 0) = 1
                       AND A.IdContrato = @IdContrato
                 ORDER BY A.CreadoEl DESC;
             END;
         IF @Case = 2
             BEGIN
                 IF EXISTS
                 (
                     SELECT TOP 1 *
                     FROM dbo.AWS_DocumentoENI A
                          JOIN dbo.CO_Contrato C ON C.IdContrato = A.IdContrato
                          JOIN dbo.AP_Usuario U ON A.CreadoPor = U.UsuarioID
                          JOIN dbo.AP_Usuario UT ON UT.UsuarioID = @IdUsuario
                          JOIN #TemporalCorreos TC ON UT.Usuario = TC.Usuario
                     WHERE A.Folder = 'ENIArchivos/JOINTVENTURE/'
                           AND ISNULL(A.Privado, 0) = 1
                           AND A.IdContrato = @IdContrato
                 )
                     BEGIN
                         SELECT 1 AS Privados;
                     END;
                     ELSE
                     BEGIN
                         SELECT 0 AS Privados;
                     END;
             END;
     END;