USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[ME_ConsultaSeccion]    Script Date: 26/11/2021 01:52:52 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <12/02/2018>
-- Description:	<Consultar secciones>
-- =============================================


ALTER procedure [dbo].[ME_ConsultaSeccion]
@IdMatrizEvaluacion int
as 
begin
	Select IdSeccion, IdMatrizEvaluacion as Matriz, Nombre, Ponderacion
		from ME_Seccion (NOLOCK)
		where IdMatrizEvaluacion=@IdMatrizEvaluacion
			AND (Activo = 1 OR Activo IS NULL);
end
