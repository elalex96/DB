USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'ReqGuardadoDocumentoAdjuntoPCMDescarga'
)
    DROP PROCEDURE ReqGuardadoDocumentoAdjuntoPCMDescarga;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <19-07-2023>
-- Description:	aplicacion de optimizaciones y estandares de desarrollo issue:https://github.com/Adinco/petrovendor/issues/2379
-- =============================================
CREATE PROCEDURE [dbo].[ReqGuardadoDocumentoAdjuntoPCMDescarga]
    @IdProveedor INT,
    @IdSolicitudPedido INT
AS
BEGIN

    SELECT IdDocumento,--0
           NombreDocumento,--1
		   Extension,--2
		   CONCAT(Carpeta,Identificador),--3
		   Mime,--4
		   Identificador,--5
		   Carpeta,--6
		   Isnull(Bucket,'') as Bucket
    FROM dbo.PCMDocumentoAdjunto (NOLOCK)
    WHERE 
          Activo = 1
		  AND IdTipoDocumento = 28 -- Requisicion de PCM adjunto
		  AND IdProveedor = @IdProveedor
          AND IdSolicitucPedido = @IdSolicitudPedido
END;