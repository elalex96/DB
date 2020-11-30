-- =============================================
-- Author: DANIEL AC
-- Create date: 31/08/2017
-- Description:	CONSULTAR ROL DE APROBACION DE TIPO DE OPERACION
-- =============================================
CREATE  PROCEDURE [dbo].[SP_MA_ConsultarRolesxTipoOperacion]

@IdUsuario INT,
@IdContrato INT,
@IdSubcontratista INT,
@FechaRegistro DATETIME = '05-02-2018 00:00'
AS 

BEGIN

	SELECT T.IdTipoOperacion, 'Aprobador de '+T.Nombre AS TipoOperacionRol
	FROM dbo.MA_TipoOperacion T
	WHERE  T.Activo=1 

	
END



