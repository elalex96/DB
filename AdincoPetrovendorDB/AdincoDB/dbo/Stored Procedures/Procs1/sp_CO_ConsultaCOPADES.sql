USE Adinco
GO
IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'sp_CO_ConsultaCOPADES'
    )
    DROP PROCEDURE sp_CO_ConsultaCOPADES;
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaCOPADES] 
@IdContrato INT = 0,
@IdUsuario  INT,
@IdCopade int = 0
AS
     BEGIN
         SET NOCOUNT ON;

         SELECT CO_COPADE.IdCopade,
                CO_COPADE.IdContrato,
                CO_COPADE.NumeroCOPADE,
                CO_COPADE.FechaEmision,
                CO_COPADE.Archivo,
			    Adjunto,
                CO_COPADE.Activo ,
                CO_COPADE.CreadoPor ,
                CO_COPADE.CreadoEn ,
                CO_COPADE.ModificadoPor,
                CO_COPADE.ModificadoEn ,
                ISNULL(CO_COPADE.DocumentoId,0) AS DocumentoId,
                UsuarioCreado.Nombre AS UsuarioCreado,
                UsuarioModificado.Nombre AS UsuarioModificado,
		        D.Bucket,
		        D.Folder,
		        D.UUIDAmazon,
		        D.NombreArchivo,
		        D.Meta
         FROM 
            CO_COPADE (NOLOCK)
        LEFT JOIN
			AWS_Documentos D	(NOLOCK) 
			ON CO_COPADE.DocumentoId = D.AWSDocumentoId
        LEFT JOIN
            AP_Usuario  UsuarioCreado (NOLOCK) 
            ON  CO_COPADE.CreadoPor =    UsuarioCreado.UsuarioID
            AND CO_COPADE.IdContrato = @IdContrato
        LEFT JOIN
            AP_Usuario  UsuarioModificado (NOLOCK) 
            ON  CO_COPADE.ModificadoPor =    UsuarioModificado.UsuarioID
         WHERE
            (CO_COPADE.IdContrato = @IdContrato) 
            and @IdCopade in (0,IdCopade)
         ORDER BY 
            NumeroCOPADE;
     END;