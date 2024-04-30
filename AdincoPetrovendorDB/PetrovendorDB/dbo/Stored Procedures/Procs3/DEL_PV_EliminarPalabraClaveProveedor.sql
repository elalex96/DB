USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'DEL_PV_EliminarPalabraClaveProveedor'
)
    DROP PROCEDURE DEL_PV_EliminarPalabraClaveProveedor; 
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Daniel AC
-- Create date: 15-04-2024
-- Description: Eliminado lógico de una palabra clave relacionada a un proveedor
-- =============================================
CREATE PROCEDURE [dbo].[DEL_PV_EliminarPalabraClaveProveedor] 
-- Add the parameters for the stored procedure here
@IdProveedor  INT,
@IdUsuario  INT,
@Id  INT
AS
BEGIN

UPDATE PV_PerfilPalabraClave
SET ModificadoPor = @IdUsuario,
ModificadoEl = GETDATE(),
Activo = 0
WHERE Id = @Id


END;