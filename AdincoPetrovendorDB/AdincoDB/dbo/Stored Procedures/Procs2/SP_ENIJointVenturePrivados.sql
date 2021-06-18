-- =============================================
-- Author:		Marcos Garcia
-- Create date: 27-07-2020
-- Description:	Seleciona solo Documentos que han sido marcados 
--              como privados por caso para ocultar el div de privados 
-- =============================================
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 18/06/2021
-- Description:	agregado de indicadores de tipo de archivos
-- =============================================
CREATE PROCEDURE [dbo].[SP_ENIJointVenturePrivados] 
-- [dbo].[SP_ENIJointVenturePrivados] 3,10113,1
@IdContrato INT, 
@IdUsuario  INT, 
@Case       INT
AS
     BEGIN
         SET NOCOUNT ON;
         --IF OBJECT_ID('tempdb..#TemporalCorreos', 'U') IS NOT NULL
         --    DROP TABLE #TemporalCorreos;
         ----
         --CREATE TABLE #TemporalCorreos
         --(Nombre  VARCHAR(MAX), 
         -- Usuario VARCHAR(MAX)
         --);
         ----
         --INSERT INTO #TemporalCorreos
         --(Nombre, 
         -- Usuario
         --)
         --VALUES
         --('Felice D´Alterio', 
         -- 'Felice.DAlterio@eni.com'
         --),
         --('Nayeli islas', 
         -- 'nayeli.islas@external.eni.com'
         --)--,
         ----('Manuel Cruz', 
         ---- 'manuel.cruz@adinco.mx'
         ----);
         ----
         --IF @Case = 1
         --    BEGIN
         --        SELECT A.IdAWSDocumento, 
         --               C.NumeroContrato AS Contrato, 
         --               A.NombreArchivo, 
         --               U.Nombre AS CreadoPor, 
         --               A.CreadoEl
         --        FROM dbo.AWS_DocumentoENI A
         --             JOIN dbo.CO_Contrato C ON C.IdContrato = A.IdContrato
         --             JOIN dbo.AP_Usuario U ON A.CreadoPor = U.UsuarioID
         --             JOIN dbo.AP_Usuario UT ON UT.UsuarioID = @IdUsuario
         --             JOIN #TemporalCorreos TC ON UT.Usuario = TC.Usuario
         --        WHERE A.Folder = 'ENIArchivos/JOINTVENTURE/'
         --              AND ISNULL(A.Privado, 0) = 1
         --              AND A.IdContrato = @IdContrato
         --        ORDER BY A.CreadoEl DESC;
         --    END;
         --IF @Case = 2
         --    BEGIN
         --        IF EXISTS
         --        (
         --            SELECT TOP 1 *
         --            FROM dbo.AWS_DocumentoENI A
         --                 JOIN dbo.CO_Contrato C ON C.IdContrato = A.IdContrato
         --                 JOIN dbo.AP_Usuario U ON A.CreadoPor = U.UsuarioID
         --                 JOIN dbo.AP_Usuario UT ON UT.UsuarioID = @IdUsuario
         --                 JOIN #TemporalCorreos TC ON UT.Usuario = TC.Usuario
         --            WHERE A.Folder = 'ENIArchivos/JOINTVENTURE/'
         --                  AND ISNULL(A.Privado, 0) = 1
         --                  AND A.IdContrato = @IdContrato
         --        )
         --            BEGIN
         --                SELECT 1 AS Privados;
         --            END;
         --            ELSE
         --            BEGIN
         --                SELECT 0 AS Privados;
         --            END;
         --    END;

		 SELECT A.Folder,
				A.IdAWSDocumento, 
				C.NumeroContrato AS Contrato,
                CASE
                    WHEN A.Folder = 'ENIArchivos/PMT/'
                    THEN 'PMT'
                    WHEN A.Folder = 'ENIArchivos/JOINTVENTURE/'
                    THEN 'JOINT VENTURE'
					WHEN A.Folder = 'ENIArchivos/PLANESAPROBADOS/'
                    THEN 'Planes Aprobados'
					when A.Folder = 'ENIArchivos/PROGRAMAMÍNIMODETRABAJO/'
					then 'Programa Mínimo de Trabajo'
                END AS Tipo, 
                NombreArchivo, 
                U.Nombre AS CreadoPor, 
                A.CreadoEl,
                CASE
                    WHEN ISNULL(A.Privado, 0) = 0
                    THEN 'Público'
                    WHEN ISNULL(A.Privado, 0) = 1
                    THEN 'Privado'
                END AS Clasificacion,
				UUIDAmazon
         FROM dbo.AWS_DocumentoENI A
              JOIN dbo.CO_Contrato C ON C.IdContrato = A.IdContrato
              JOIN dbo.AP_Usuario U ON A.CreadoPor = U.UsuarioID
		 WHERE A.Privado = 1
		 AND A.Folder = 'ENIArchivos/JOINTVENTURE/'
         ORDER BY A.CreadoEl DESC;

END;