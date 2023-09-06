USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'MM_ConsultarLocalidades'
)
    DROP PROCEDURE MM_ConsultarLocalidades;
/****** Object:  StoredProcedure [dbo].[MM_ConsultarLocalidades]    Script Date: 28/08/2023 03:57:11 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Daniel AC
-- Create date: <04-09-2023>
-- Description:	Consultar las localidades del proveedor/operadora actual 
-- =============================================
CREATE PROCEDURE [dbo].[MM_ConsultarLocalidades] 
@IdProveedor INT ,
@IdContrato INT,
@IdUsuario INT
AS
BEGIN	
					
		
	SELECT L.Id AS IdLocalidad, L.Nombre
	FROM MM_Localidades L (NOLOCK)	
	WHERE L.IdProveedor = @IdProveedor
	AND L.Activo = 1 --> QUE ESTE ACTIVA	
	ORDER BY Nombre ASC


END