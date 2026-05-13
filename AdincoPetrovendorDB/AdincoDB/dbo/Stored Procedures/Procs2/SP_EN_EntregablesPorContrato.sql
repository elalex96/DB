-- =============================================
-- Author:		Manuel CD
-- Create date: 22-11-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_EntregablesPorContrato]
	-- Add the parameters for the stored procedure here
@IdContrato INT,
@IdUsuario  INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
             SELECT D.IdDocumento AS 'IdDocumentoEntregable',
                    R.Regulador AS 'Regulador',
                    D.FechaDocumento AS 'Fecha del documento',
                    D.NoReferencia,
                    D.NombreDocumento AS 'Nombre del documento',
                    LT.Nombre AS 'Tipo',
                    LAP.Nombre AS 'Actividad petrolera',
                    CONCAT(E.Consecutivo, ' - ',E.DocumentoEntregable) AS 'DocumentoEntregable',
                    CASE
                        WHEN D.Archivo IS NULL
                        THEN 'NO CARGADO'
                        ELSE 'Cargado'
                    END AS 'Archivo',
				U.Nombre AS 'Creado Por',
				D.CreadoEl AS 'Creado El'
             FROM dbo.EN_Documento D
                  JOIN dbo.EN_Entregable E ON D.IdEntregable = E.IdEntregable
					AND E.BITJOA = 0
                  JOIN dbo.CO_Regulador R ON E.IdRegulador = R.IdRegulador
                  JOIN dbo.AP_Lista LT ON D.ClvTipo = LT.IdClave
                                          AND LT.IdGrupo = 10007
                  JOIN dbo.AP_Lista LAP ON D.IdActividadPetrolera = LAP.IdClave
                                           AND LAP.IdGrupo = 10006
			   JOIN dbo.AP_Usuario U ON D.CreadoPor = U.UsuarioID
             WHERE D.IdContrato = @IdContrato
             ORDER BY IdDocumentoEntregable DESC;
         END;