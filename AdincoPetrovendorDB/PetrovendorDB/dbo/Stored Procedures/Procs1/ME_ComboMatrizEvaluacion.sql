USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[ME_ComboMatrizEvaluacion]    Script Date: 26/11/2021 01:37:35 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <09/02/2018>
-- Description:	<Consulta para combo Matriz de Evaluación>
-- =============================================
ALTER procedure [dbo].[ME_ComboMatrizEvaluacion]
	@IdProveedor int
as 
begin
	SELECT IdMatrizEvaluacion, Nombre
		from dbo.ME_MatrizEvaluacion WITH (NOLOCK)
		where IdProveedorEvaluador = @IdProveedor
			AND IdTipoEvaluacion = 1
			AND (Activo = 1 OR Activo IS NULL)
END

