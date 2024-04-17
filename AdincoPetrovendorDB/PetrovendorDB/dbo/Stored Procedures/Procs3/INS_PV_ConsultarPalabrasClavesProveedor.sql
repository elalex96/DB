USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'INS_PV_ConsultarPalabrasClavesProveedor'
)
    DROP PROCEDURE INS_PV_ConsultarPalabrasClavesProveedor; 
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Daniel AC
-- Create date: 16-04-2024
-- Description: Agregar nueva palabra clave al proveedor
-- =============================================
CREATE PROCEDURE [dbo].[INS_PV_ConsultarPalabrasClavesProveedor] 
-- Add the parameters for the stored procedure here
@IdProveedor  INT,
@IdCategoria INT,
@PalabraClave VARCHAR(MAX),
@CreadoPor INT,
@Activo INT

AS
BEGIN

IF NOT EXISTS(SELECT * FROM PV_PerfilPalabraClave
WHERE IdCategoria =@IdCategoria AND IdProveedor = @IdProveedor)
BEGIN

	INSERT INTO PV_PerfilPalabraClave(IdCategoria,PalabraClave,Activo,IdProveedor,CreadoPor,CreadoEl)
	VALUES(@IdCategoria,@PalabraClave,@Activo,@IdProveedor,@CreadoPor,GETDATE())

END 

SELECT Id FROM PV_PerfilPalabraClave
WHERE IdCategoria =@IdCategoria
AND IdProveedor = @IdProveedor

END;