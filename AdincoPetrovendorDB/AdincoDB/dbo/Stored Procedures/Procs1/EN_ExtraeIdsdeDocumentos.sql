-- =============================================
-- Author:		Reyna Olvera
-- Create date: 13/04/2018
-- Description:	Extrae los id de los documentos para poder ser descargados en formas de zip
-- =============================================
CREATE PROCEDURE [dbo].[EN_ExtraeIdsdeDocumentos] --10061,3,147925,13054,10000
    @idUsuario INT, @idContrato INT, @idInstanciaEntregable INT, @idEntregable INT, @idTipoArchivo INT
AS BEGIN
    SET NOCOUNT ON;
    SELECT DocumentoEntregableId
    FROM EN_EntregableDocumento
    WHERE idInstanciaEntregable=@idInstanciaEntregable AND idContratoEntregable=(SELECT IdContratoEntregable
                                                                                 FROM EN_ContratoEntregable
                                                                                 WHERE IdContrato=@idContrato AND IdEntregable=@idEntregable
        --  AND FechaLimiteEntrega IS NOT NULL
        )
          -- AND DocumentoEntregableId != 1
          AND Activo=1 AND idTipoArchivo=@idTipoArchivo;
END;
