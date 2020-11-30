CREATE view  ModulosAMostrar as
select PM.IdPerfil, M.StringModuloId from PerfilModulo as PM inner join Modulo as M on PM.IdModulo = M.IdModulo where PM.IdPerfil = 4 

