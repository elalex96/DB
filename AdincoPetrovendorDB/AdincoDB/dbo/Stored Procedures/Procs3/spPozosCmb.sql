
create proc spPozosCmb
(
	@IdContrato	int
)
as
begin
	select		Id					=	IdInstalacion,
				Nombre				=	NombreInstalacion 
	FROM		dbo.CO_Instalacion	i
	INNER JOIN	dbo.CO_Contrato		c 
	ON			c.IdAreaContractual =	i.IdAreaContractual
	WHERE		c.IdContrato		=	@IdContrato 
	AND			i.Activo			=	1
end


--select * from sys.tables where name like '%instala%'

--select * from CO_Instalacion where Activo = 1
----/01Proveedores/SP_NuevaSolicitudPedido.aspx //Procura
----http://localhost:52694/2/Entregables/CalculoFechasProcesos.aspx //Adinco

----NombreProgramaciónProcesos

--CO_SP_ConsultaInstalacionesPorContrato