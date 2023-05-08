
CREATE PROCEDURE [dbo].[SP_PV_ConsutarProveedoresADINCO]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    create table #tempProveedoresCalificados( --Tabla temporal que guardara los proveedores de adinco que tengan un ususario de petrovendor
	IdRow int,
	IdSubcontratista int, 
	IdUsuarioPetrovendor int,
	RFC varchar(30), 
	RazonSocial varchar(max), 
	NacionalidadID int, 
	Pais nvarchar(max),
	Entidad nvarchar(max), 
	Municipio nvarchar(max),
	CalificacionProveedor decimal null
	)

	insert into #tempProveedoresCalificados 
	select 
	ROW_NUMBER() OVER(ORDER BY IdSubcontratista ASC),
	IdSubcontratista,IdPetroVendor, RFC, RazonSocial, NacionalidadID, Pais, Entidad, Municipio, 0
	from Adinco.dbo.PV_Subcontratista where IsEliminado = 0 and IdPetroVendor is not null 


	declare @UsuariosPetrovendorEnAdinco int
	declare @Contador int
	declare @petrovendor int
	set @UsuariosPetrovendorEnAdinco = (select count(IdUsuarioPetrovendor) from #tempProveedoresCalificados)

	set @Contador = 1
	while (@Contador < @UsuariosPetrovendorEnAdinco)
	begin

    create table #tempCalificacion(
	NumeroEstrellas int
	)
	
	set @petrovendor = (select IdUsuarioPetrovendor from #tempProveedoresCalificados where IdRow = @Contador) -- Obtiene el IdUsuario petrovendor

	
	insert into #tempCalificacion exec Petrovendor.dbo.SP_EP_ValoracionEstrellas @IdProveedorEvaluado = @petrovendor --	                                                                                                                   .
	declare @estrellas decimal                                                                                             --Consultamos la calificación del proveedor
	set @estrellas = (select NumeroEstrellas from #tempCalificacion)                                                 --

	Update #tempProveedoresCalificados set
	CalificacionProveedor = @estrellas
	where IdUsuarioPetrovendor = @petrovendor
    
	drop table #tempCalificacion

	set @Contador = @Contador + 1

	end

	select * from #tempProveedoresCalificados
	 

	----------------------------------------------------------------------------------------

	--create table #tempProveedores(
	--IdRow int,
	--IdUsuarioAdinco int,
	--IdUsuarioPetrovendor int
	--)

	--insert into #tempProveedores select
	--ROW_NUMBER() OVER(ORDER BY IdSubcontratista ASC),
	--IdSubcontratista,
	--IdPetroVendor
	--from Adinco.dbo.PV_Subcontratista
	--where IsEliminado = 0 and IdPetroVendor is not null


	--create table #tempProveedoresCalificados(
	--IdSubcontratista int, 
	--RFC varchar(30), 
	--RazonSocial varchar(max), 
	--NacionalidadID int, 
	--Pais nvarchar(max),
	--Entidad nvarchar(max), 
	--Municipio nvarchar(max),
	--CalificacionProveedor int
	--)

	--declare @UsuariosPetrovendorEnAdinco int
	--declare @Contador int
	--declare @petrovendor int
	--set @UsuariosPetrovendorEnAdinco = (select count(IdUsuarioPetrovendor) from #tempProveedores)

	--set @Contador = 1
	--while (@Contador < @UsuariosPetrovendorEnAdinco)
	--begin

 --   create table #tempCalificacion(
	--NumeroEstrellas int
	--)
	
	--set @petrovendor = (select IdUsuarioPetrovendor from #tempProveedores where IdRow = @Contador)

	--insert into #tempCalificacion exec Petrovendor.dbo.SP_EP_ValoracionEstrellas @IdProveedorEvaluado = @petrovendor
	--declare @estrellas int
	--set @estrellas = (select NumeroEstrellas from #tempCalificacion)

	----declare @Adinco int 
	----set @Adinco = (select IdUsuarioAdinco from #tempProveedores where IdUsuarioPetrovendor = @petrovendor)

	--insert into #tempProveedoresCalificados 
	--select 
	--IdSubcontratista, RFC, RazonSocial, NacionalidadID, Pais, Entidad, Municipio ,@estrellas
	--from Adinco.dbo.PV_Subcontratista where  IdPetroVendor = @petrovendor
 --   ORDER BY IdSubcontratista

	--drop table #tempCalificacion

	--set @Contador = @Contador + 1

	--end

	--select * from #tempProveedoresCalificados

		--SELECT
		--	IdSubcontratista, RazonSocial, COUNT(*)
		--FROM
		--	#tempProveedoresCalificados
		--GROUP BY
		--	IdSubcontratista, RazonSocial
		--HAVING 
		--	COUNT(*) > 1

    --select IdSubcontratista, RFC, RazonSocial, NacionalidadID, Pais, Entidad, Municipio
    --from Adinco.DBo.PV_Subcontratista where IsEliminado = 'false'

END
