USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_ConsultarTipoUnidad]    Script Date: 26/11/2021 01:54:21 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[SP_ConsultarTipoUnidad]
	@Id INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT [Unidad] FROM [PV_MM_MaterialUnidad] (NOLOCK) WHERE IdUnidad = @Id
END
