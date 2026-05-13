
-- =============================================
-- Author:		Pedro acuna
-- Create date: 05-02-2020
-- Description:	Se guarda la referencia al documento adjunto de PCM que esta en la requisicion 
-- =============================================
CREATE PROCEDURE ReqGuardadoDocumentoAdjuntoPCM @IdUsuario         INT, 
                                                @IdProveedor       INT, 
                                                @Carpeta           NVARCHAR(MAX), 
                                                @Identificador     NVARCHAR(MAX), 
                                                @Mime              NVARCHAR(300), 
                                                @Extension         NVARCHAR(300), 
                                                @NombreDocumento   NVARCHAR(MAX), 
                                                @IdSolicitudPedido INT, 
                                                @IdTipoDocumento   INT
AS
    BEGIN
        DECLARE @IdDocumento INT;
        INSERT INTO dbo.PCMDocumentoAdjunto
        (IdSolicitucPedido, 
         IdTipoDocumento, 
         IdProveedor, 
         Activo, 
         CreadoPor, 
         CreadoEl, 
         ModificadoPor, 
         ModificadoEl, 
         Descripcion, 
         Carpeta, 
         Identificador, 
         Mime, 
         Extension, 
         NombreDocumento
        )
        VALUES
        (@IdSolicitudPedido, -- IdSolicitucPedido - int
         @IdTipoDocumento, -- IdTipoDocumento - int
         @IdProveedor, -- IdProveedor - int
         1, -- Activo - bit
         @IdUsuario, -- CreadoPor - int
         GETDATE(), -- CreadoEl - datetime
         NULL, -- ModificadoPor - int
         NULL, -- ModificadoEl - datetime
         N'', -- Descripcion - nvarchar(max)
         @Carpeta, -- Carpeta - nvarchar(max)
         @Identificador, -- Identificador - nvarchar(max)
         @Mime, -- Mime - nvarchar(500)
         @Extension, -- Extension - nvarchar(500)
         @NombreDocumento    -- NombreDocumento - nvarchar(max)
        );
    END;